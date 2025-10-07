//
//  BridgewellEventSDK.swift
//  BridgewellEventSDK
//
//  Created by Nguyễn Mai Quân on 19/9/25.
//

import Foundation
import WebKit
import AdSupport
import AppTrackingTransparency
import CoreLocation
import Network

/**
 BridgewellEventSDK - iOS SDK for event tracking and WebView integration

 This SDK provides functionality for:
 - Event tracking and analytics
 - WebView injection with device/app information
 - Secure data collection with privacy compliance

 Usage:
 ```swift
// Initialize SDK
 let config = BridgewellConfig(loggingEnabled: true)
 BridgewellEvent.shared.initialize(config: config)

 // Register WebView for ad info injection
 BridgewellEvent.shared.registerContentWebViewWithAdInfo(webView)
```
 */
@objcMembers
public final class BridgewellEvent: NSObject, @unchecked Sendable {

    // MARK: - Singleton

    /// Shared singleton instance
    @objc public static let shared = BridgewellEvent()

    /// Private initializer to enforce singleton pattern
    private override init() {
        super.init()
    }

    // MARK: - Public Properties

    /// Current SDK version constant
    @objc public static let sdkVersion = "0.0.1"

    /// Runtime accessor for SDK version
    @objc public var version: String {
        return BridgewellEvent.sdkVersion
    }

    /// Location services enabled flag
    /// When enabled, the SDK will collect geographic information (lat/lon, country, city)
    /// Requires location permissions from the user
    @objc public var isLocationEnabled: Bool = true

    // MARK: - Private Properties

    private var isInitialized = false
    private var configuration: BridgewellConfig?
    private let logger = BridgewellLogger()
    private var webKitHandler: BridgewellWebKitHandler?

    // MARK: - Public Methods

    /// Initialize the SDK with configuration
    /// - Parameter config: Configuration object for SDK initialization
    @objc public func initialize(config: BridgewellConfig) {
        guard !isInitialized else {
            logger.log("SDK already initialized", level: .warning)
            return
        }

        configuration = config
        logger.isEnabled = config.loggingEnabled
        isInitialized = true

        logger.log("BridgewellEventSDK v\(BridgewellEvent.sdkVersion) initialized", level: .info)
    }

    /// Inject basic SDK data into WebView (callback-based) - Generic version
    ///
    /// **Note**: This method only injects basic mobile data (app_id, idfa_adid).
    /// For comprehensive device data injection including BwsDevice, BwsGeo, etc.,
    /// use `registerContentWebViewWithAdInfo(_:)` instead.
    ///
    /// - Parameters:
    ///   - webView: Target WebView for injection (must be WKWebView)
    ///   - completion: Completion handler with success status and optional error
    @objc public func inject(webView: Any, completion: ((Bool, Error?) -> Void)? = nil) {
        guard isInitialized else {
            let error = BridgewellError.notInitialized
            logger.log("SDK not initialized", level: .error)
            completion?(false, error)
            return
        }

        // Check if it's a UIWebView (deprecated)
        if let webViewClass = webView as? AnyClass {
            if NSStringFromClass(webViewClass) == "UIWebView" {
                let error = BridgewellError.unsupportedWebView
                logger.log("UIWebView is not supported. Please use WKWebView instead.", level: .error)
                completion?(false, error)
                return
            }
        }

        // Check if it's a WKWebView
        guard let wkWebView = webView as? WKWebView else {
            let error = BridgewellError.unsupportedWebView
            logger.log("Unsupported WebView type. Only WKWebView is supported.", level: .error)
            completion?(false, error)
            return
        }

        // Proceed with WKWebView injection
        inject(wkWebView: wkWebView, completion: completion)
    }

    /// Inject basic SDK data into WKWebView (callback-based) - Typed version
    ///
    /// **Note**: This method only injects basic mobile data (app_id, idfa_adid).
    /// For comprehensive device data injection including BwsDevice, BwsGeo, etc.,
    /// use `registerContentWebViewWithAdInfo(_:)` instead.
    ///
    /// - Parameters:
    ///   - wkWebView: Target WKWebView for injection
    ///   - completion: Completion handler with success status and optional error
    @objc public func inject(wkWebView: WKWebView,
                                   completion: ((Bool, Error?) -> Void)? = nil) {
        guard isInitialized else {
            let error = BridgewellError.notInitialized
            logger.log("SDK not initialized", level: .error)
            completion?(false, error)
            return
        }

        performInjectionSync(webView: wkWebView, completion: completion)
    }

    /// Inject basic SDK data into WebView (async/await - iOS 13.0+)
    ///
    /// **Note**: This method only injects basic mobile data (app_id, idfa_adid).
    /// For comprehensive device data injection including BwsDevice, BwsGeo, etc.,
    /// use `registerContentWebViewWithAdInfo(_:)` instead.
    ///
    /// - Parameter webView: Target WKWebView for injection
    /// - Returns: Success status
    /// - Throws: BridgewellError if injection fails
    @available(iOS 13.0, *)
    public func inject(webView: WKWebView) async throws -> Bool {
        guard isInitialized else {
            logger.log("SDK not initialized", level: .error)
            throw BridgewellError.notInitialized
        }

        return try await performInjection(webView: webView)
    }

    /// Register WKWebView for comprehensive content and ad info injection
    ///
    /// **Recommended Method**: This method injects complete device data including:
    /// - BwsDevice: Device information (platform, model, screen size, etc.)
    /// - BwsGeo: Geographic information (timezone, location data)
    /// - BwsMobile: Mobile app information (app_id, IDFA, etc.)
    /// - SDK version and metadata
    ///
    /// This method waits for the WebView to finish loading before injection and will call
    /// the `window.onSdkDataReady(mobile, geo, device, sdk)` JavaScript function when ready.
    ///
    /// - Parameter webView: The WKWebView to register for data injection
    @objc public func registerContentWebViewWithAdInfo(_ webView: WKWebView) {
        guard isInitialized else {
            logger.log("SDK not initialized - cannot register WebView", level: .error)
            return
        }

        logger.log("Registering WebView for comprehensive content and ad info injection", level: .info)

        webKitHandler = BridgewellWebKitHandler()
        webKitHandler?.registerWebViewAsync(webView)

        logger.log("WebView registered with comprehensive data handler", level: .info)
    }

    // MARK: - Private Methods

    private func performInjectionSync(webView: WKWebView, completion: ((Bool, Error?) -> Void)?) {
        let appId = getAppId()

        // Get IDFA synchronously
        let idfaAdid = getIDFASync()

        let jsPayload = createJavaScriptPayload(appId: appId, idfaAdid: idfaAdid)

        logger.log("Injecting payload into WebView", level: .debug)

        webView.evaluateJavaScript(jsPayload) { result, error in
            if let error = error {
                self.logger.log("JavaScript injection failed: \(error.localizedDescription)", level: .error)
                completion?(false, BridgewellError.injectionFailed(error))
            } else {
                self.logger.log("JavaScript injection successful", level: .info)
                completion?(true, nil)
            }
        }
    }

    @available(iOS 13.0, *)
    private func performInjection(webView: WKWebView) async throws -> Bool {
        let appId = getAppId()
        let idfaAdid = await getIDFA()

        let jsPayload = createJavaScriptPayload(appId: appId, idfaAdid: idfaAdid)

        logger.log("Injecting payload into WebView", level: .debug)

        if #available(iOS 13.0, *) {
            return try await withCheckedThrowingContinuation { [weak self] continuation in
                DispatchQueue.main.async {
                    webView.evaluateJavaScript(jsPayload) { result, error in
                        if let error = error {
                            self?.logger.log("JavaScript injection failed: \(error.localizedDescription)", level: .error)
                            continuation.resume(throwing: BridgewellError.injectionFailed(error))
                        } else {
                            self?.logger.log("JavaScript injection successful", level: .info)
                            continuation.resume(returning: true)
                        }
                    }
                }
            }
        } else {
            // Fallback for iOS < 13.0 (though this method is marked as iOS 13.0+)
            throw BridgewellError.unsupportedWebView
        }
    }

    private func createJavaScriptPayload(appId: String, idfaAdid: String) -> String {
        let payload = """
        window.bwsMobile = {
            app_id: "\(appId)",
            idfa_adid: "\(idfaAdid)"
        };
        """

        if configuration?.loggingEnabled == true {
            logger.log("JS Payload: \(payload)", level: .debug)
        }

        return payload
    }

    private func getAppId() -> String {
        if let override = configuration?.appIdOverride, !override.isEmpty {
            return override
        }

        // Try to get App Store ID from Info.plist, fallback to bundle identifier
        if let appStoreId = Bundle.main.object(forInfoDictionaryKey: "AppStoreId") as? String {
            return appStoreId
        }

        return Bundle.main.bundleIdentifier ?? "unknown"
    }

    @available(iOS 10.0, *)
    private func getIDFASync() -> String {
        if #available(iOS 14, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus

            switch status {
            case .authorized:
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            case .denied, .restricted, .notDetermined:
                logger.log("IDFA access denied or not determined", level: .info)
                return ""
            @unknown default:
                logger.log("Unknown ATT status", level: .warning)
                return ""
            }
        } else {
            // For iOS < 14, check if advertising tracking is enabled
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            } else {
                return ""
            }
        }
    }

    private func getIDFA() async -> String {
        return getIDFASync()
    }

    // MARK: - Testing Support

    /// Reset SDK state for testing purposes
    /// - Note: This method is intended for testing only
    @objc public func resetForTesting() {
        isInitialized = false
        configuration = nil
    }
}

