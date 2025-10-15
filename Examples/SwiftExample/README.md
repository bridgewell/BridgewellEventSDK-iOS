# Swift Example App

This example demonstrates how to integrate BridgewellEventSDK in a Swift iOS application.

## Features Demonstrated

- SDK initialization with configuration
- WebView setup and loading
- Asynchronous injection using both callback and async/await patterns
- Error handling and logging
- ATT permission handling
- JavaScript verification of injected data

## Requirements

- iOS 12.0+
- Xcode 14.0+
- Swift 5.7+

## Installation

### Option 1: Swift Package Manager (Recommended)

1. Open `SwiftExample.xcodeproj` in Xcode
2. File → Add Package Dependencies
3. Enter: `https://github.com/bridgewell/iOS-BridgewellEventSDK.git`
4. Select version `0.1.0` or later

### Option 2: Local Development

For local development and testing:

1. Open `SwiftExample.xcodeproj`
2. Add local package reference to the SDK
3. Build and run

## Usage

1. **Initialize SDK**: The app initializes the SDK in `viewDidLoad`
2. **Request ATT Permission**: Tap "Request ATT Permission" to request tracking authorization
3. **Load WebView**: The WebView loads a test HTML page
4. **Inject Data**: Tap "Inject SDK Data" to inject app information
5. **Verify**: Check the WebView content to see injected data

## Code Structure

```
SwiftExample/
├── SwiftExample.xcodeproj
├── SwiftExample/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── ViewController.swift
│   ├── Main.storyboard
│   ├── LaunchScreen.storyboard
│   ├── Info.plist
│   └── test.html
└── README.md
```

## Key Implementation Points

### SDK Initialization
```swift
let config = BridgewellConfig(
    appIdOverride: nil,
    loggingEnabled: true
)
BridgewellEventSDK.initialize(config: config)
```

### ATT Permission Request
```swift
ATTrackingManager.requestTrackingAuthorization { status in
    // Handle permission result
}
```

### WebView Injection (Async/Await)
```swift
do {
    let success = try await BridgewellEventSDK.inject(webView: webView)
    print("Injection successful: \(success)")
} catch {
    print("Injection failed: \(error)")
}
```

### WebView Injection (Callback)
```swift
BridgewellEventSDK.inject(webView: webView) { success, error in
    if success {
        print("Injection successful")
    } else {
        print("Injection failed: \(error?.localizedDescription ?? "Unknown error")")
    }
}
```

## Testing

1. **Simulator Testing**: Basic functionality works in simulator (IDFA will be empty)
2. **Device Testing**: Full functionality including IDFA requires physical device
3. **ATT Testing**: ATT permission dialog only appears on physical device

## Troubleshooting

### Common Issues

1. **IDFA returns empty**: Normal in simulator or when ATT permission denied
2. **Injection fails**: Ensure WebView has finished loading
3. **Build errors**: Verify SDK is properly added to project

### Debug Tips

1. Enable logging in SDK configuration
2. Check Xcode console for SDK logs
3. Use Safari Web Inspector to debug WebView JavaScript
4. Verify ATT permission status in device settings

## Next Steps

- Customize the HTML content for your use case
- Implement proper error handling for production
- Add analytics or other integrations using the injected data
- Test thoroughly on physical devices
