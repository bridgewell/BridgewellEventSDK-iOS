# registerContentWebViewWithAdInfo Feature Documentation

## Overview

The `registerContentWebViewWithAdInfo` feature provides advanced WebView integration for the BridgewellEventSDK, enabling automatic injection of device, mobile, and geographic information into web content for improved ad monetization.

## Feature Description

This feature registers a WKWebView with the Bridgewell SDK to improve in-app ad monetization of ads within the web view. The implementation is non-blocking and asynchronously injects comprehensive device and app information into the WebView's JavaScript context.

## API Reference

### Main Method

```swift
@objc public func registerContentWebViewWithAdInfo(_ webView: WKWebView)
```

**Parameters:**
- `webView`: The WKWebView to register for data injection

**Requirements:**
- SDK must be initialized before calling this method
- WebView should be properly configured and ready for content loading

**Usage:**
```swift
BridgewellSDK.shared.registerContentWebViewWithAdInfo(webView)
```

## Implementation Details

### Data Collection

The feature collects and injects the following data types:

#### 1. Mobile Information (`window.bwsMobile`)
- `isApp`: Always true for mobile app context
- `appIdentifier`: Bundle identifier of the host app
- `advertisingID`: IDFA (with proper ATT compliance)

#### 2. Geographic Information (`window.bwsGeo`)
- `utcoffset`: UTC offset in minutes
- Location data (when available and permitted)

#### 3. Device Information (`window.bwsDevice`)
- `platform`: "iOS"
- `brand`: "Apple"
- `model`: Device model identifier
- `osVersion`: iOS version components (major, minor, micro)
- `carrier`: Mobile carrier name
- `screenWidth`/`screenHeight`: Screen dimensions in pixels
- `screenRatio`: Screen pixel ratio in millis
- `screenOrientation`: Current device orientation
- `hardwareVersion`: Hardware identifier
- `limitAdTracking`: Ad tracking limitation status
- `appTrackingStatus`: ATT authorization status (iOS 14+)
- `connection`: Network connection type

#### 4. SDK Information (`window.bwsdk`)
- `sdk_version`: SDK version with installation method indicator

### JavaScript Integration

The feature injects data into the WebView and calls the `window.onSdkDataReady` callback function when available:

```javascript
// Data is available as global variables
console.log(window.bwsMobile);
console.log(window.bwsGeo);
console.log(window.bwsDevice);
console.log(window.bwsdk);

// Callback function (implement in your web content)
function onSdkDataReady(mobile, geo, device, sdk) {
    // Handle the injected data
    console.log('SDK data ready:', { mobile, geo, device, sdk });
}
```

### Timing and Lifecycle

1. **Registration**: Call `registerContentWebViewWithAdInfo` after SDK initialization
2. **Data Preparation**: SDK asynchronously collects device and app information
3. **WebView Loading**: SDK monitors WebView navigation completion
4. **Data Injection**: When both data and WebView are ready, injection occurs
5. **Callback Execution**: `window.onSdkDataReady` is called if available

## Usage Examples

### Basic Usage

```swift
import BridgewellEventSDK
import WebKit

class ViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize SDK
        let config = BridgewellConfig(loggingEnabled: true)
        BridgewellSDK.shared.initialize(config: config)

        // Register WebView for ad info injection
        BridgewellSDK.shared.registerContentWebViewWithAdInfo(webView)

        // Load your web content
        if let url = URL(string: "https://your-web-content.com") {
            webView.load(URLRequest(url: url))
        }
    }
}
```

### Web Content Integration

```html
<!DOCTYPE html>
<html>
<head>
    <title>Ad-Enabled Content</title>
</head>
<body>
    <script>
        // Define callback to receive SDK data
        function onSdkDataReady(mobile, geo, device, sdk) {
            console.log('Received SDK data:');
            console.log('Mobile:', mobile);
            console.log('Geo:', geo);
            console.log('Device:', device);
            console.log('SDK:', sdk);
            
            // Use data for ad targeting or analytics
            if (mobile && JSON.parse(mobile).advertisingID) {
                // IDFA available for ad targeting
                setupPersonalizedAds(JSON.parse(mobile).advertisingID);
            }
        }
        
        // Fallback if callback isn't called immediately
        setTimeout(function() {
            if (window.bwsMobile) {
                onSdkDataReady(window.bwsMobile, window.bwsGeo, window.bwsDevice, window.bwsdk);
            }
        }, 1000);
    </script>
</body>
</html>
```

## Privacy and Compliance

### App Tracking Transparency (ATT)

The feature automatically handles ATT compliance:
- IDFA is only provided when user has granted tracking permission
- `limitAdTracking` flag indicates tracking preference
- `appTrackingStatus` provides detailed ATT status

### Data Collection

All data collection respects user privacy settings:
- Location data requires appropriate permissions
- Advertising ID follows ATT guidelines
- No sensitive personal information is collected

## Error Handling

The feature includes robust error handling:
- Graceful degradation when data is unavailable
- Retry mechanisms for JavaScript injection
- Logging for debugging (when enabled)

## Performance Considerations

- **Asynchronous**: All operations are non-blocking
- **Efficient**: Data is collected once and cached
- **Lightweight**: Minimal impact on WebView performance
- **Optimized**: JavaScript injection is batched and sequential

## Troubleshooting

### Common Issues

1. **Data not available**: Ensure SDK is initialized before registration
2. **Callback not called**: Check JavaScript console for errors
3. **Missing IDFA**: Verify ATT permission status
4. **Timing issues**: Use fallback mechanisms in web content

### Debug Logging

Enable debug logging to troubleshoot issues:

```swift
let config = BridgewellConfig(loggingEnabled: true)
BridgewellSDK.shared.initialize(config: config)
```

## Migration from Basic Injection

If migrating from the basic `inject` method:

```swift
// Old approach
BridgewellSDK.shared.inject(webView: webView) { success in
    // Handle completion
}

// New approach
BridgewellSDK.shared.registerContentWebViewWithAdInfo(webView)
// Callback handling moved to JavaScript
```

## Best Practices

1. **Initialize Early**: Initialize SDK as early as possible in app lifecycle
2. **Register Before Loading**: Register WebView before loading content
3. **Handle Callbacks**: Always implement `onSdkDataReady` in web content
4. **Respect Privacy**: Check tracking permissions before using IDFA
5. **Test Thoroughly**: Test with different ATT permission states
6. **Monitor Performance**: Use debug logging to monitor injection timing

## Related APIs

- `BridgewellSDK.shared.initialize(config:)` - SDK initialization
- `BridgewellSDK.shared.inject(webView:completion:)` - Basic injection method
- `BridgewellSDK.shared.version` - Runtime SDK version accessor
- `BridgewellSDK.sdkVersion` - Static SDK version constant
- `BridgewellConfig` - SDK configuration options
- `BridgewellError` - Error handling
