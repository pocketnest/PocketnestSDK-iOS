import SwiftUI
import WebKit
import AuthenticationServices

struct PocketnestWebView: UIViewRepresentable {
    let url: String
    let redirectUri: String?
    let onSuccess: ([String: Any]) -> Void
    let onExit: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(redirectUri: redirectUri, onSuccess: onSuccess, onExit: onExit)
    }

    func makeUIView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()

        // Inject bridge for native -> web
        let bridgeJS = """
        window.HostBridge = window.HostBridge || {};
        window.HostBridge.onHostedLinkComplete = function (payload) {
            try {
                const data = typeof payload === 'string' ? JSON.parse(payload) : payload;
                window.dispatchEvent(new CustomEvent('hosted-link-complete', { detail: data }));
            } catch (e) {
                console.error('HostBridge payload parse error', e);
            }
        };
        """
        contentController.addUserScript(
            WKUserScript(source: bridgeJS, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        )

        // Web -> native messages
        contentController.add(context.coordinator, name: "onSuccess")
        contentController.add(context.coordinator, name: "onExit")
        contentController.add(context.coordinator, name: "native") // hosted link trigger

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        context.coordinator.webView = webView

        if let url = URL(string: url + "?redirectUri=" + (redirectUri ?? "")) {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    // MARK: - Coordinator
    class Coordinator: NSObject, WKScriptMessageHandler, ASWebAuthenticationPresentationContextProviding {
        weak var webView: WKWebView?
        let redirectUri: String?
        let onSuccess: ([String: Any]) -> Void
        let onExit: () -> Void
        var authSession: ASWebAuthenticationSession?

        init(redirectUri: String?, onSuccess: @escaping ([String: Any]) -> Void, onExit: @escaping () -> Void) {
            self.redirectUri = redirectUri
            self.onSuccess = onSuccess
            self.onExit = onExit
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case "onSuccess":
                if let data = message.body as? [String: Any] {
                    onSuccess(data)
                }
            case "onExit":
                onExit()
            case "native":
                // Expect { type: "openHostedLink", url: "https://..." }
                if let dict = message.body as? [String: Any],
                   let type = dict["type"] as? String,
                   type == "openHostedLink",
                   let urlString = dict["url"] as? String {
                    openHostedLink(urlString)
                }
            default:
                break
            }
        }

        // MARK: - Hosted Link (Plaid)
        private func openHostedLink(_ urlString: String) {
            guard let url = URL(string: urlString) else { return }
            guard let redirectUri = redirectUri else {
                print("⚠️ No redirectUri provided, cannot open hosted link")
                return
            }

            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: redirectUri
            ) { [weak self] callbackURL, error in
                guard let self = self else { return }

                if let error = error as? ASWebAuthenticationSessionError,
                   error.code == .canceledLogin {
                    self.notifyWeb(status: "cancel", url: nil, params: [:])
                    self.onExit()
                    return
                }

                guard let callbackURL = callbackURL else {
                    self.notifyWeb(status: "error", url: nil, params: [:])
                    return
                }

                var params: [String: String] = [:]
                if let comps = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false) {
                    comps.queryItems?.forEach { params[$0.name] = $0.value ?? "" }
                }

                let payload: [String: Any] = [
                    "status": "success",
                    "callbackURL": callbackURL.absoluteString,
                    "params": params
                ]

                self.notifyWeb(status: "success", url: callbackURL.absoluteString, params: params)
                self.onSuccess(payload)
            }

            session.prefersEphemeralWebBrowserSession = false
            session.presentationContextProvider = self
            self.authSession = session
            session.start()
        }

        private func notifyWeb(status: String, url: String?, params: [String: String]) {
            let payload: [String: Any] = [
                "status": status,
                "callbackURL": url ?? "",
                "params": params
            ]
            guard let data = try? JSONSerialization.data(withJSONObject: payload),
                  let json = String(data: data, encoding: .utf8) else { return }

            let js = "window.HostBridge.onHostedLinkComplete(\(json))"
            webView?.evaluateJavaScript(js, completionHandler: nil)
        }

        // MARK: - ASWebAuthenticationSession
        func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
            webView?.window ?? ASPresentationAnchor()
        }
    }
}
