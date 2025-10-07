//
//  BridgewellError.swift
//  BridgewellEventSDK
//
//  Created by Nguyễn Mai Quân on 18/9/25.
//

import Foundation

/// Errors that can occur during SDK operations
@objc public enum BridgewellError: Int, Error, LocalizedError {
    case notInitialized = 1000
    case injectionFailed = 1001
    case webViewNotReady = 1002
    case invalidConfiguration = 1003
    case unsupportedWebView = 1004

    // Manual implementation of allCases for Objective-C compatibility
    public static let allCases: [BridgewellError] = [
        .notInitialized,
        .injectionFailed,
        .webViewNotReady,
        .invalidConfiguration,
        .unsupportedWebView
    ]
    
    public var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "BridgewellEventSDK has not been initialized. Call initialize(config:) first."
        case .injectionFailed:
            return "Failed to inject JavaScript into WebView."
        case .webViewNotReady:
            return "WebView is not ready for JavaScript injection."
        case .invalidConfiguration:
            return "Invalid configuration provided to SDK."
        case .unsupportedWebView:
            return "UIWebView is deprecated and not supported. Please use WKWebView instead."
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .notInitialized:
            return "SDK initialization was not called before attempting to use SDK features."
        case .injectionFailed:
            return "JavaScript evaluation failed in the WebView context."
        case .webViewNotReady:
            return "WebView has not finished loading or is in an invalid state."
        case .invalidConfiguration:
            return "Configuration object contains invalid or conflicting settings."
        case .unsupportedWebView:
            return "UIWebView has been deprecated since iOS 12.0 and is not supported by this SDK."
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .notInitialized:
            return "Call BridgewellEventSDK.initialize(config:) before using any SDK features."
        case .injectionFailed:
            return "Ensure the WebView has finished loading and try again."
        case .webViewNotReady:
            return "Wait for the WebView to finish loading before attempting injection."
        case .invalidConfiguration:
            return "Review the configuration parameters and ensure they are valid."
        case .unsupportedWebView:
            return "Replace UIWebView with WKWebView in your application. UIWebView is deprecated and no longer supported."
        }
    }
}

// MARK: - Error Factory

extension BridgewellError {
    static func injectionFailed(_ underlyingError: Error) -> BridgewellError {
        // In a more complex implementation, we could store the underlying error
        return .injectionFailed
    }
}

// MARK: - Objective-C Bridge

@objc public class BridgewellErrorHelper: NSObject {
    @objc public static func notInitializedError() -> NSError {
        return BridgewellError.notInitialized as NSError
    }

    @objc public static func injectionFailedError() -> NSError {
        return BridgewellError.injectionFailed as NSError
    }

    @objc public static func webViewNotReadyError() -> NSError {
        return BridgewellError.webViewNotReady as NSError
    }

    @objc public static func invalidConfigurationError() -> NSError {
        return BridgewellError.invalidConfiguration as NSError
    }

    @objc public static func unsupportedWebViewError() -> NSError {
        return BridgewellError.unsupportedWebView as NSError
    }
}
