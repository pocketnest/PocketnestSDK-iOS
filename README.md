# PocketnestSDK

![PocketnestSDK](https://img.shields.io/badge/PocketnestSDK-1.0.1-success)

iOS SDK for Pocketnest.

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

```swift
dependencies: [
    .package(url: "https://github.com/pocketnest/PocketnestSDK-iOS.git", .upToNextMajor(from: "1.0.0"))
]
```

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate PocketnestSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'PocketnestSDK', :git => 'https://github.com/pocketnest/PocketnestSDK-iOS.git', :tag => '1.0.1'
```

## Usage

Configure the redirect URI in your Xcode project:

- In your Xcode project, select your target and go to the **Info** tab.
- Scroll to the bottom and add a new **URL Type**.
- Set the **URL Schemes** field to your redirect URI (e.g., `myssoredirect`).
For example, use `myssoredirect` or any other name you prefer; you will provide this value in the SDK configuration later.

Here's official Apple documentation on how to register a custom URL scheme:
https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app#Register-your-URL-scheme


```swift
import PocketnestSDK

let url = "YOUR_SSO_URL" // Example: https://mywebsite.com/sso provided by Pocketnest prod or preprod
let redirectUri = "YOUR_REDIRECT_URI" // This value must exactly match the scheme registered in your Xcode project's URL Types (including case sensitivity) to avoid integration issues
let accessToken = "YOUR_ACCESS_TOKEN" // Optional, if you want to user to be logged in automatically (session)

// SwiftUI version
PocketnestSDK.webViewUI(url: url, accessToken:accessToken, redirectUri: redirectUri, onSuccess: { 
    //Optional, Handle success SDK (webview) opened
}, onExit: {
    //Optional, Handle exit SDK (webview)
})


// UIKit version
PocketnestSDK.webView(url: url, accessToken:accessToken, redirectUri: redirectUri, onSuccess: { 
    //Optional, if you want to user to be logged in automatically (session)
}, onExit: {
    //Optional, Handle exit SDK (webview)
})

```
Function `webView` returns `UIView` that you can present in your app however you want.

You can check the example project in the `Example` folder.
 

