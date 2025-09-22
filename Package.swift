// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PocketnestSDK",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "PocketnestSDK",
            targets: ["PocketnestSDK"]
        ),
    ],
    targets: [
        .target(
            name: "PocketnestSDK",
            dependencies: []
        ),
        .testTarget(
            name: "PocketnestSDKTests",
            dependencies: ["PocketnestSDK"]
        ),
    ]
)
