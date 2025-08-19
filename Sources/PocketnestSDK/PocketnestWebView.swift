import SwiftUI
import WebKit

struct PocketnestWebView: UIViewRepresentable {
    let pocketnestUrl: String
    let onSuccess: ([String: Any]) -> Void
    let onExit: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSuccess: onSuccess, onExit: onExit)
    }

    func makeUIView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "onSuccess")
        contentController.add(context.coordinator, name: "onExit")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)

        if let url = URL(string: pocketnestUrl) {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKScriptMessageHandler {
        let onSuccess: ([String: Any]) -> Void
        let onExit: () -> Void

        init(onSuccess: @escaping ([String: Any]) -> Void, onExit: @escaping () -> Void) {
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
                default:
                    break
            }
        }
    }
}
