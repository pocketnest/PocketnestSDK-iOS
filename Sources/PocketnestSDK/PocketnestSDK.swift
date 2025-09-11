import SwiftUI

public struct PocketnestSDK {
    @MainActor public static func launch(
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
