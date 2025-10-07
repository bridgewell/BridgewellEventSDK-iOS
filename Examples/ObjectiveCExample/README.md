# Objective-C Example App

This example demonstrates how to integrate BridgewellEventSDK in an Objective-C iOS application.

## Features Demonstrated

- SDK initialization from Objective-C
- WebView integration
- Callback-based injection
- Error handling in Objective-C
- ATT permission handling
- JavaScript verification of injected data

## Requirements

- iOS 12.0+
- Xcode 14.0+
- Objective-C compatible project

## Installation

### CocoaPods (Recommended for Objective-C)

1. Create or update `Podfile`:
```ruby
platform :ios, '12.0'
use_frameworks!

target 'ObjectiveCExample' do
  pod 'BridgewellEventSDK', '~> 0.1.0'
end
```

2. Run:
```bash
pod install
```

3. Open `ObjectiveCExample.xcworkspace`

### Swift Package Manager

1. Open `ObjectiveCExample.xcodeproj` in Xcode
2. File → Add Package Dependencies
3. Enter: `https://github.com/bridgewell/iOS-BridgewellEventSDK.git`
4. Select version `0.1.0` or later

## Usage

1. **Initialize SDK**: The app initializes the SDK in `viewDidLoad`
2. **Request ATT Permission**: Tap "Request ATT Permission" button
3. **Load WebView**: The WebView loads a test HTML page
4. **Inject Data**: Tap "Inject SDK Data" to inject app information
5. **Verify**: Check the WebView content to see injected data

## Code Structure

```
ObjectiveCExample/
├── ObjectiveCExample.xcodeproj
├── ObjectiveCExample/
│   ├── AppDelegate.h
│   ├── AppDelegate.m
│   ├── SceneDelegate.h
│   ├── SceneDelegate.m
│   ├── ViewController.h
│   ├── ViewController.m
│   ├── Main.storyboard
│   ├── LaunchScreen.storyboard
│   ├── Info.plist
│   └── test.html
├── Podfile
└── README.md
```

## Key Implementation Points

### Import Statement
```objc
#import <BridgewellEventSDK/BridgewellEventSDK-Swift.h>
```

### SDK Initialization
```objc
BridgewellConfig *config = [[BridgewellConfig alloc] 
    initWithAppIdOverride:nil 
    loggingEnabled:YES];
[BridgewellEventSDK initializeWithConfig:config];
```

### ATT Permission Request
```objc
[ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
    // Handle permission result
}];
```

### WebView Injection
```objc
[BridgewellEventSDK injectWithWebView:self.webView 
                           completion:^(BOOL success, NSError *error) {
    if (success) {
        NSLog(@"Injection successful");
    } else {
        NSLog(@"Injection failed: %@", error.localizedDescription);
    }
}];
```

## Bridging Header

If using Swift Package Manager, you may need to configure bridging:

### Project Settings
1. Build Settings → Swift Compiler - General
2. Set "Install Objective-C Compatibility Header" to YES
3. Import the generated header in your Objective-C files

### Manual Bridging Header
Create `ObjectiveCExample-Bridging-Header.h`:
```objc
#import <BridgewellEventSDK/BridgewellEventSDK-Swift.h>
```

## Testing

1. **Simulator Testing**: Basic functionality works (IDFA will be empty)
2. **Device Testing**: Full functionality including IDFA requires physical device
3. **ATT Testing**: ATT permission dialog only appears on physical device

## Common Objective-C Patterns

### Error Handling
```objc
NSError *error = nil;
BOOL success = [SomeMethod performActionWithError:&error];
if (!success) {
    NSLog(@"Error: %@", error.localizedDescription);
}
```

### Completion Blocks
```objc
[BridgewellEventSDK injectWithWebView:self.webView 
                           completion:^(BOOL success, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update UI on main queue
        [self updateUIWithSuccess:success error:error];
    });
}];
```

### Property Declaration
```objc
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (strong, nonatomic) BridgewellConfig *sdkConfig;
```

## Troubleshooting

### Common Issues

1. **Import errors**: Ensure proper import of Swift header
2. **Linking errors**: Verify framework is properly linked
3. **Runtime errors**: Check that use_frameworks! is in Podfile

### Debug Tips

1. Enable verbose logging in configuration
2. Check that Swift header is generated correctly
3. Verify module imports in build settings
4. Use Xcode's Swift/Objective-C interface inspector

### CocoaPods Specific

If using CocoaPods:
```ruby
# Ensure use_frameworks! is enabled
use_frameworks!

# For static libraries, use:
# use_frameworks! :linkage => :static
```

## Migration from Pure Objective-C

If migrating from a pure Objective-C project:

1. Enable Swift support in project settings
2. Add bridging header if needed
3. Update deployment target to iOS 12.0+
4. Configure module imports properly

## Next Steps

- Customize the HTML content for your use case
- Implement proper error handling for production
- Add analytics or other integrations using the injected data
- Consider migrating to Swift for new features (optional)
