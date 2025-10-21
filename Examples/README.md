# BridgewellEventSDK Examples

This directory contains example projects demonstrating how to integrate and use BridgewellEventSDK in both Swift and Objective-C applications.

## Available Examples

### 1. SwiftExample
A complete iOS app written in Swift that demonstrates:
- SDK initialization with configuration
- WebView setup and loading
- Asynchronous injection using both callback and async/await patterns
- Error handling and logging
- ATT permission handling

**Location**: `SwiftExample/`

**Key Features**:
- Modern Swift implementation
- Async/await support (iOS 13.0+)
- Comprehensive error handling
- UI for testing different scenarios

### 2. SwiftUIExample
A complete iOS app written in SwiftUI that demonstrates:
- SDK initialization with configuration
- SwiftUI-based modern UI architecture
- WebView integration using UIViewRepresentable
- Asynchronous SDK setup and data injection
- Error handling and loading states
- ATT permission handling

**Location**: `SwiftUIExample/`

**Key Features**:
- Modern SwiftUI implementation (iOS 13.0+)
- Declarative UI with state management
- UIViewRepresentable for WebView integration
- Comprehensive error handling
- Loading states and user feedback

### 3. ObjectiveCExample
A complete iOS app written in Objective-C that demonstrates:
- SDK initialization from Objective-C
- WebView integration
- Callback-based injection
- Error handling in Objective-C

**Location**: `ObjectiveCExample/`

**Key Features**:
- Pure Objective-C implementation
- Demonstrates Objective-C compatibility
- Traditional callback patterns
- Integration with existing Objective-C codebases

## Getting Started

### Prerequisites
- Xcode 14.0 or later
- iOS 12.0 or later
- Valid Apple Developer account (for device testing with ATT)

### Running the Examples

#### Swift Example
1. Navigate to `Examples/SwiftExample/`
2. Open `BRG-SwiftExample.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project

#### SwiftUI Example
1. Navigate to `Examples/SwiftUIExample/`
2. Open `BRG-SwiftUIExample.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project

#### Objective-C Example
1. Navigate to `Examples/ObjectiveCExample/`
2. Open `BRG-ObjectiveCExample.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project

### Installation Methods Demonstrated

Each example project demonstrates different installation methods:

#### Swift Package Manager (SwiftExample & SwiftUIExample)
The Swift and SwiftUI examples use SPM integration:
- File → Add Package Dependencies
- Enter: `https://github.com/bridgewell/iOS-BridgewellEventSDK.git`

#### CocoaPods (ObjectiveCExample)
The Objective-C example uses CocoaPods:
```ruby
# Podfile
pod 'BridgewellEventSDK', '~> 0.1.0'
```

## Testing Features

Both examples include UI for testing:

### Core Features
- ✅ SDK initialization
- ✅ WebView injection
- ✅ JavaScript verification
- ✅ Error handling
- ✅ Configuration options

### Privacy Features
- ✅ ATT permission request
- ✅ IDFA handling with consent
- ✅ Privacy-compliant behavior

### Advanced Features
- ✅ Custom app ID override
- ✅ Logging configuration
- ✅ Multiple WebView scenarios
- ✅ Retry mechanisms

## Code Snippets

### Swift Integration
```swift
import BridgewellEventSDK

// Initialize SDK
let config = BridgewellConfig(
    appIdOverride: nil,
    loggingEnabled: true
)
BridgewellEventSDK.initialize(config: config)

// Inject into WebView (async/await)
do {
    let success = try await BridgewellEventSDK.inject(webView: webView)
    print("Injection successful: \(success)")
} catch {
    print("Injection failed: \(error)")
}
```

### Objective-C Integration
```objc
#import <BridgewellEventSDK/BridgewellEventSDK-Swift.h>

// Initialize SDK
BridgewellConfig *config = [[BridgewellConfig alloc] 
    initWithAppIdOverride:nil 
    loggingEnabled:YES];
[BridgewellEventSDK initializeWithConfig:config];

// Inject into WebView (callback)
[BridgewellEventSDK injectWithWebView:self.webView 
                           completion:^(BOOL success, NSError *error) {
    if (success) {
        NSLog(@"Injection successful");
    } else {
        NSLog(@"Injection failed: %@", error.localizedDescription);
    }
}];
```

## JavaScript Verification

Both examples include JavaScript code to verify the injection:

```javascript
// Check if SDK data is available
if (window.bwsMobile) {
    console.log('App ID:', window.bwsMobile.app_id);
    console.log('IDFA:', window.bwsMobile.idfa_adid);
    
    // Display in UI
    document.getElementById('app-id').textContent = window.bwsMobile.app_id;
    document.getElementById('idfa').textContent = window.bwsMobile.idfa_adid || 'Not available';
} else {
    console.log('BridgewellEventSDK data not available');
}
```

## Troubleshooting

### Common Issues

1. **SDK not initialized error**
   - Ensure `BridgewellEventSDK.initialize(config:)` is called before injection

2. **IDFA returns empty string**
   - Check ATT permission status
   - Ensure user has granted tracking permission

3. **WebView injection fails**
   - Verify WebView has finished loading
   - Check JavaScript console for errors

4. **Objective-C compilation errors**
   - Ensure proper import: `#import <BridgewellEventSDK/BridgewellEventSDK-Swift.h>`
   - Check bridging header configuration

### Debug Tips

1. Enable logging in configuration:
   ```swift
   let config = BridgewellConfig(loggingEnabled: true)
   ```

2. Check JavaScript console in WebView:
   ```javascript
   console.log('BridgewellEventSDK:', window.bwsMobile);
   ```

3. Verify ATT status:
   ```swift
   import AppTrackingTransparency
   print("ATT Status:", ATTrackingManager.trackingAuthorizationStatus.rawValue)
   ```

## Contributing

When adding new examples:

1. Follow the existing project structure
2. Include comprehensive comments
3. Demonstrate error handling
4. Add README with specific instructions
5. Test on both simulator and device
6. Verify ATT functionality on device

## Support

For questions about the examples:
- 📧 Email: support@bridgewell.com
- 🐛 Issues: [GitHub Issues](https://github.com/bridgewell/iOS-BridgewellEventSDK/issues)
- 📖 Documentation: [Full API Documentation](https://bridgewell.github.io/iOS-BridgewellEventSDK/)
