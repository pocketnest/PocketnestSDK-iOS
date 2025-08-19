import SwiftUI

public struct PocketnestSDK {
    @MainActor public static func launch(
        url: String,
        onSuccess: @escaping ([String: Any]) -> Void,
        onExit: @escaping () -> Void
    ) -> some View {
        PocketnestWebView(
            pocketnestUrl: url,
            onSuccess: onSuccess,
            onExit: onExit
        )
    }
}
