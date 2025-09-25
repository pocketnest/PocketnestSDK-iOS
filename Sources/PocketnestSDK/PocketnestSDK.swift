import SwiftUI

public struct PocketnestSDK {
    /**
     - Returns: A SwiftUI view representing the Pocketnest web view.
     */
    @MainActor public static func webView(
        url: String,
        redirectUri: String? = nil,
        onSuccess: @escaping ([String: Any]) -> Void,
        onExit: @escaping () -> Void
    ) -> some View {
        PocketnestWebView(
            url: url,
            redirectUri: redirectUri,
            onSuccess: onSuccess,
            onExit: onExit
        )
    }
}
