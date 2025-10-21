# SwiftUI Example App

This example demonstrates how to integrate BridgewellEventSDK in a modern SwiftUI iOS application.

## Features Demonstrated

- SDK initialization with configuration
- SwiftUI-based UI architecture
- WebView integration using UIViewRepresentable
- Asynchronous SDK setup and data injection
- Error handling and loading states
- ATT permission handling
- JavaScript verification of injected data

## Requirements

- iOS 13.0+
- Xcode 14.0+
- Swift 5.5+
- SwiftUI framework

## Project Structure

```
SwiftUIExample/
├── BRG-SwiftUIExample.xcodeproj
├── BRG-SwiftUIExample/
│   ├── App.swift                    # Main SwiftUI app entry point
│   ├── ContentView.swift            # Main UI view with WebView
│   ├── Assets.xcassets              # App icons and assets
│   ├── Info.plist                   # App configuration
│   └── test-device-injection.html   # Test HTML for SDK data verification
├── README.md
└── test.html
```

## Installation

### Option 1: Swift Package Manager (Recommended)

1. Open `BRG-SwiftUIExample.xcodeproj` in Xcode
2. File → Add Package Dependencies
3. Enter: `https://github.com/bridgewell/iOS-BridgewellEventSDK.git`
4. Select version `0.1.0` or later

### Option 2: Local Development

For local development and testing:

1. Open the workspace containing both the SDK and example
2. The SDK framework will be automatically linked

## Key Implementation Points

### SwiftUI App Entry Point

```swift
@main
struct BRGSwiftUIExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### SDK Initialization

```swift
let config = BridgewellConfig(
    appIdOverride: nil,
    loggingEnabled: true
)
BridgewellEvent.shared.initialize(config: config)
```

### WebView Integration with UIViewRepresentable

```swift
struct WebViewRepresentable: UIViewRepresentable {
    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update logic if needed
    }
}
```

### Registering WebView for Data Injection

```swift
BridgewellEvent.shared.registerContentWebViewWithAdInfo(webView)
```

## SwiftUI-Specific Features

### State Management

The example uses SwiftUI's `@State` property wrapper to manage:
- WebView container
- Loading state
- Error messages

### View Composition

The UI is composed of reusable SwiftUI views:
- Header with app information
- WebView container with loading indicator
- Error message display

### Async/Await Pattern

SDK setup is performed asynchronously to prevent blocking the UI:

```swift
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    loadWebContent()
}
```

## Testing

### Simulator Testing
- Basic functionality works (IDFA will be empty)
- WebView content loads and displays correctly
- SDK data injection can be verified through JavaScript

### Device Testing
- Full functionality including IDFA requires physical device
- ATT permission dialog only appears on physical device
- Location services work with proper permissions

### Verification

1. Run the app in Xcode
2. The app will initialize the SDK and load a test webpage
3. The webpage displays injected SDK data including:
   - Mobile device information
   - Geo location data
   - Device specifications
   - SDK metadata

## Common SwiftUI Patterns

### Conditional View Display

```swift
if let container = webViewContainer {
    WebViewRepresentable(webView: container.webView)
} else {
    ProgressView()
}
```

### Error Handling

```swift
if let error = errorMessage {
    VStack {
        // Error UI
    }
}
```

### View Lifecycle

SwiftUI views use `.onAppear` modifier for initialization:

```swift
.onAppear {
    setupSDK()
}
```

## Troubleshooting

### WebView Not Loading
- Ensure the SDK is initialized before registering the WebView
- Check that the HTML file exists in the app bundle
- Verify network connectivity for remote URLs

### SDK Data Not Injected
- Confirm `registerContentWebViewWithAdInfo` is called
- Check browser console for JavaScript errors
- Verify permissions are granted (Location, ATT)

### Build Errors
- Ensure BridgewellEventSDK framework is properly linked
- Check that WebKit framework is included in build phases
- Verify Swift version compatibility (5.5+)

## Differences from UIKit Example

| Aspect | UIKit | SwiftUI |
|--------|-------|---------|
| Entry Point | AppDelegate | @main App |
| View Hierarchy | Storyboard/Code | Declarative |
| State Management | Properties | @State/@StateObject |
| WebView Integration | Direct UIView | UIViewRepresentable |
| Lifecycle | Delegate methods | View modifiers |

## Best Practices

1. **Initialize SDK Early**: Call SDK initialization in `onAppear` or app startup
2. **Handle Loading States**: Show loading indicator while SDK initializes
3. **Error Handling**: Display user-friendly error messages
4. **Memory Management**: Ensure WebView is properly retained
5. **Permissions**: Request necessary permissions (Location, ATT) upfront

## Additional Resources

- [SwiftUI Documentation](https://developer.apple.com/xcode/swiftui/)
- [WebKit Framework](https://developer.apple.com/documentation/webkit)
- [BridgewellEventSDK Documentation](../../docs/)

## Support

For issues or questions about the SDK integration, please refer to the main SDK documentation or contact support.

