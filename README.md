# BridgewellEventSDK

[![CI](https://github.com/bridgewell/iOS-BridgewellEventSDK/actions/workflows/ci.yml/badge.svg)](https://github.com/bridgewell/iOS-BridgewellEventSDK/actions/workflows/ci.yml)
[![CD](https://github.com/bridgewell/iOS-BridgewellEventSDK/actions/workflows/cd.yml/badge.svg)](https://github.com/bridgewell/iOS-BridgewellEventSDK/actions/workflows/cd.yml)
[![CocoaPods](https://img.shields.io/cocoapods/v/BridgewellEventSDK.svg)](https://cocoapods.org/pods/BridgewellEventSDK)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Platform](https://img.shields.io/cocoapods/p/BridgewellEventSDK.svg)](https://cocoapods.org/pods/BridgewellEventSDK)

## Overview

**BridgewellEventSDK** is an iOS SDK that provides an event/bridge layer for iOS applications. It offers a secure, asynchronous mechanism to inject app and device information into in-app WebViews via the `window.bwsMobile` JavaScript object.

### Key Features

- 🚀 **Easy Integration**: Support for both Swift Package Manager and CocoaPods
- 🔄 **Cross-Language Support**: Compatible with both Swift and Objective-C projects
- 🌐 **WebView Integration**: Seamless injection of app data into JavaScript environment
- 🔐 **Privacy Compliant**: Respects ATT consent for IDFA access
- ⚡ **Asynchronous**: Non-blocking UI operations
- 🧪 **Well Tested**: High test coverage with comprehensive CI/CD

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/bridgewell/iOS-BridgewellEventSDK.git", from: "0.1.0")
]
```

Or add it through Xcode:
1. File > Add Package Dependencies
2. Enter: `https://github.com/bridgewell/iOS-BridgewellEventSDK.git`

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'BridgewellEventSDK', '~> 0.1.0'
```

Then run:

```bash
pod install
```

## Quick Start

### Swift

```swift
import BridgewellEventSDK
import WebKit

class ViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the SDK
        let config = BridgewellConfig(
            appIdOverride: nil,
            loggingEnabled: true
        )
        BridgewellEventSDK.initialize(config: config)
        
        // Load your web content
        if let url = URL(string: "https://your-website.com") {
            webView.load(URLRequest(url: url))
        }
        
        // Inject SDK data into WebView
        BridgewellEventSDK.inject(webView: webView) { success, error in
            if success {
                print("Successfully injected BridgewellEventSDK data")
            } else {
                print("Failed to inject data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
```

### Swift with async/await (iOS 13.0+)

```swift
import BridgewellEventSDK

@available(iOS 13.0, *)
class ModernViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                let success = try await BridgewellEventSDK.inject(webView: webView)
                print("Injection successful: \(success)")
            } catch {
                print("Injection failed: \(error)")
            }
        }
    }
}
```

### Objective-C

```objc
#import <BridgewellEventSDK/BridgewellEventSDK-Swift.h>
#import <WebKit/WebKit.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the SDK
    BridgewellConfig *config = [[BridgewellConfig alloc] initWithAppIdOverride:nil 
                                                               loggingEnabled:YES];
    [BridgewellEventSDK initializeWithConfig:config];
    
    // Load your web content
    NSURL *url = [NSURL URLWithString:@"https://your-website.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    // Inject SDK data into WebView
    [BridgewellEventSDK injectWithWebView:self.webView 
                               completion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"Successfully injected BridgewellEventSDK data");
        } else {
            NSLog(@"Failed to inject data: %@", error.localizedDescription);
        }
    }];
}

@end
```

## API Reference

### BridgewellEventSDK

The main SDK class providing core functionality.

#### Properties

```swift
@objc public static let version: String // Current SDK version
```

#### Methods

```swift
// Initialize the SDK with configuration
@objc public static func initialize(config: BridgewellConfig)

// Inject data into WebView (callback-based)
@objc public static func inject(webView: WKWebView, 
                               completion: ((Bool, Error?) -> Void)? = nil)

// Inject data into WebView (async/await - iOS 13.0+)
@available(iOS 13.0, *)
public static func inject(webView: WKWebView) async throws -> Bool
```

### BridgewellConfig

Configuration object for SDK initialization.

#### Properties

```swift
@objc public var appIdOverride: String?    // Override for app ID
@objc public var loggingEnabled: Bool      // Enable/disable logging
```

#### Initializers

```swift
@objc public init(appIdOverride: String? = nil, loggingEnabled: Bool = false)
```

## JavaScript Integration

Once injected, the SDK provides the following JavaScript object:

```javascript
window.bwsMobile = {
    app_id: "com.mycompany.myapp",        // App bundle identifier or store ID
    idfa_adid: "E4B9C6C6-ABC1-23DE..."   // IDFA (empty string if unavailable)
}
```

### Usage in WebView

```javascript
// Check if SDK data is available
if (window.bwsMobile) {
    console.log('App ID:', window.bwsMobile.app_id);
    console.log('IDFA:', window.bwsMobile.idfa_adid);
    
    // Use the data for analytics, personalization, etc.
    analytics.setAppId(window.bwsMobile.app_id);
}
```

## Privacy & Security

### ATT Compliance

The SDK respects App Tracking Transparency (ATT) consent:

- ✅ **Consent Granted**: IDFA is included in `idfa_adid`
- ❌ **Consent Denied**: `idfa_adid` returns empty string
- ⏳ **Not Determined**: `idfa_adid` returns empty string

### Best Practices

- Always check ATT status before relying on IDFA data
- Implement proper error handling for injection failures
- Consider user privacy preferences in your implementation

```swift
import AppTrackingTransparency

// Request ATT consent before SDK injection
ATTrackingManager.requestTrackingAuthorization { status in
    // Initialize and inject SDK after consent handling
    BridgewellEventSDK.inject(webView: webView) { success, error in
        // Handle injection result
    }
}
```

## Development

### Requirements

- iOS 12.0+
- Xcode 14.0+
- Swift 5.7+

### Building from Source

```bash
# Clone the repository
git clone https://github.com/bridgewell/iOS-BridgewellEventSDK.git
cd iOS-BridgewellEventSDK

# Open in Xcode
open BridgewellEventSDK.xcodeproj

# Or build from command line
xcodebuild -scheme BridgewellEventSDK -destination 'platform=iOS Simulator,name=iPhone 14' build
```

### Running Tests

```bash
# Run unit tests
xcodebuild test -scheme BridgewellEventSDK -destination 'platform=iOS Simulator,name=iPhone 14'

# Run with coverage
xcodebuild test -scheme BridgewellEventSDK -destination 'platform=iOS Simulator,name=iPhone 14' -enableCodeCoverage YES
```

### Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## CI/CD

This project uses GitHub Actions for continuous integration and deployment:

### CI Workflow
- Runs on every push and pull request
- Executes unit tests and UI tests
- Performs code formatting checks
- Generates coverage reports

### CD Workflow
- Triggers on version tags (`v*.*.*`)
- Publishes to CocoaPods
- Updates Swift Package Manager
- Creates GitHub releases

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed release history.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📧 Email: support@bridgewell.com
- 📖 Documentation: [Full API Documentation](https://bridgewell.github.io/iOS-BridgewellEventSDK/)
- 🐛 Issues: [GitHub Issues](https://github.com/bridgewell/iOS-BridgewellEventSDK/issues)

---