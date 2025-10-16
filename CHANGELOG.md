# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release preparation
- CI/CD workflows for automated testing and publishing

### Changed
- Updated Package.swift to include all source files
- Fixed platform availability issues for iOS deployment

### Fixed
- Swift Package Manager build configuration
- Platform-specific imports and availability checks

## [0.1.0] - 2024-10-15

### Added
- Initial release of BridgewellEventSDK
- WebView integration with JavaScript injection
- Support for both Swift and Objective-C projects
- CocoaPods and Swift Package Manager support
- Privacy-compliant IDFA access with ATT consent handling
- Asynchronous, non-blocking operations
- Comprehensive documentation and examples
- MIT License

### Features
- **Easy Integration**: Support for both Swift Package Manager and CocoaPods
- **Cross-Language Support**: Compatible with both Swift and Objective-C projects
- **WebView Integration**: Seamless injection of app data into JavaScript environment
- **Privacy Compliant**: Respects ATT consent for IDFA access
- **Asynchronous**: Non-blocking UI operations
- **Well Tested**: High test coverage with comprehensive CI/CD

### API
- `BridgewellEventSDK.initialize(config:)` - Initialize the SDK with configuration
- `BridgewellEventSDK.inject(webView:completion:)` - Inject data into WebView (callback-based)
- `BridgewellEventSDK.inject(webView:)` - Inject data into WebView (async/await - iOS 13.0+)
- `BridgewellConfig` - Configuration object for SDK initialization
- JavaScript object: `window.bwsMobile` with `app_id` and `idfa_adid` properties

### Requirements
- iOS 13.0+
- Xcode 14.0+
- Swift 5.7+
- CocoaPods 1.10.0+ (for CocoaPods integration)

### Installation

#### CocoaPods
```ruby
pod 'BridgewellEventSDK', '~> 0.1.0'
```

#### Swift Package Manager
```swift
dependencies: [
    .package(url: "https://github.com/bridgewell/iOS-BridgewellEventSDK.git", from: "0.1.0")
]
```
