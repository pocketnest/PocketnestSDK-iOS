import SwiftUI
import WebKit
import AuthenticationServices

struct PocketnestWebView: UIViewRepresentable {
    let url: String
    let redirectUri: String?
    let onSuccess: ([String: Any]) -> Void
    let onExit: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(baseURL: url, redirectUri: redirectUri, onSuccess: onSuccess, onExit: onExit)
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
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        context.coordinator.webView = webView

        if var components = URLComponents(string: url) {
            var queryItems = components.queryItems ?? []
            queryItems.append(URLQueryItem(name: "redirect_uri", value: redirectUri))
            components.queryItems = queryItems
            
            if let finalURL = components.url {
                webView.load(URLRequest(url: finalURL))
            }
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.navigationDelegate = context.coordinator
        uiView.uiDelegate = context.coordinator
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, WKScriptMessageHandler, ASWebAuthenticationPresentationContextProviding, WKNavigationDelegate, WKUIDelegate {
        weak var webView: WKWebView?
        let redirectUri: String?
        let baseURL: String!
        let onSuccess: ([String: Any]) -> Void
        let onExit: () -> Void
        var authSession: ASWebAuthenticationSession?

        init(baseURL:String, redirectUri: String?, onSuccess: @escaping ([String: Any]) -> Void, onExit: @escaping () -> Void) {
            self.baseURL = baseURL;
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
        
        
 
        private lazy var baseHostAndScheme: (host: String?, scheme: String?) = {
            let comps = URLComponents(string: baseURL)
            return (comps?.host, comps?.scheme)
        }()
        
        private func isExternal(_ targetURL: URL, relativeTo webView: WKWebView) -> Bool {
            let (baseHost, baseScheme) = baseHostAndScheme
            let targetHost = targetURL.host
            let targetScheme = targetURL.scheme

            let hostDiffers = (baseHost != nil && targetHost != nil &&
                               baseHost!.caseInsensitiveCompare(targetHost!) != .orderedSame)
            let schemeDiffers = (baseScheme != nil && targetScheme != nil &&
                                 baseScheme!.caseInsensitiveCompare(targetScheme!) != .orderedSame)
            return hostDiffers || schemeDiffers
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationResponse: WKNavigationResponse,
                     decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            let url = navigationResponse.response.url ?? (navigationResponse.response as? HTTPURLResponse)?.url
            if let url, isExternal(url, relativeTo: webView) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
          
        }
       
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            guard let url = navigationAction.request.url else { return nil }

            if isExternal(url, relativeTo: webView) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return nil // don't load inside the webview
            }

            // internal link opened in a new window → load in same webview
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }

    }
}
