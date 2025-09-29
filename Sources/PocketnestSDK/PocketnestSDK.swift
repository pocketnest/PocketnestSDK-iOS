import SwiftUI

public struct PocketnestSDK {
    // SwiftUI version
    /**
     - Returns: A SwiftUI view representing the Pocketnest web view.
     - Parameters:
     - url: The URL of the web view.
     - accessToken: Optional: The access token to be used for authentication.
     - redirectUri: Optional: The redirect URI to be used for redirect after Plaid Oauth flow.
     - onSuccess: Optional: A closure that is called when the web view is opened successfully.
     - onExit: Optional: A closure that is called when the web view is closed.
     */
    @MainActor public static func webViewUI(
        url: String,
        accessToken: String? = nil,
        redirectUri: String? = nil,
        onSuccess: @escaping () -> Void?,
        onExit: @escaping () -> Void?
    ) -> some View {
        PocketnestWebView(
            url: url,
            accessToken: accessToken,
            redirectUri: redirectUri,
            onSuccess: onSuccess,
            onExit: onExit
        ).onAppear {
            if (onSuccess != nil) {
                onSuccess()// fired when presented
            } }
        .onDisappear {
            if (onExit != nil) {
                onExit()// fired when leaving/dismissed
            }
        }
    }
    
    
    // UIKit version
    /**
     - Returns: A UIView view representing the Pocketnest web view.
     - Parameters:
     - url: The URL of the web view.
     - accessToken: Optional: The access token to be used for authentication.
     - redirectUri: Optional: The redirect URI to be used for redirect after Plaid Oauth flow.
     - onSuccess: Optional: A closure that is called when the web view is opened successfully.
     - onExit: Optional: A closure that is called when the web view is closed.
     */
    @MainActor public static func webView(
        url: String,
        accessToken: String? = nil,
        redirectUri: String? = nil,
        onSuccess: @escaping () -> Void?,
        onExit: @escaping () -> Void?
    ) -> UIView {
        let view = PocketnestWebView(
            url: url,
            accessToken: accessToken,
            redirectUri: redirectUri,
            onSuccess: onSuccess,
            onExit: onExit
        ).onAppear {
            if (onSuccess != nil) {
                onSuccess()// fired when presented
            } }
        .onDisappear {
            if (onExit != nil) {
                onExit()// fired when leaving/dismissed
            }
        }
        return UIHostingController(rootView: view).view;
    }
}
