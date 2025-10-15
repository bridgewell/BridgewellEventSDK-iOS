// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BridgewellEventSDK",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BridgewellEventSDK",
            targets: ["BridgewellEventSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // No external dependencies for this SDK
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        .target(
            name: "BridgewellEventSDK",
            dependencies: [],
            path: "BridgewellEventSDK/BridgewellEventSDK",
            sources: [
                "BridgewellEventSDK.swift",
                "BridgewellConfig.swift",
                "BridgewellError.swift",
                "BridgewellLogger.swift",
                "BridgewellLocationManager.swift",
                "BridgewellWebKitHandler.swift",
                "BridgewellDataModels.swift",
                "BridgewellDataHelper.swift",
                "BridgewellNetworkMonitor.swift"
            ],
            publicHeadersPath: nil,
            cSettings: nil,
            cxxSettings: nil,
            swiftSettings: [
                .define("SPM_BUILD")
            ],
            linkerSettings: nil
        ),
        .testTarget(
            name: "BridgewellEventSDKTests",
            dependencies: ["BridgewellEventSDK"],
            path: "BridgewellEventSDK/BridgewellEventSDKTests",
            sources: [
                "BridgewellEventSDKTests.swift"
            ]
        ),
    ]
)
