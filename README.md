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

let webView = PocketnestSDK.webView(url: url, redirectUri: redirectUri, onSuccess: { data in
    // Handle success SDK started
}, onExit: {
    // Handle exit SDK
})

```

You can check the example project in the `Example` folder.
 

