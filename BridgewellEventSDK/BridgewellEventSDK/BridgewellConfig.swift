//
//  BridgewellConfig.swift
//  BridgewellEventSDK
//
//  Created by Nguyễn Mai Quân on 18/9/25.
//

import Foundation

/// Configuration object for BridgewellEventSDK initialization
@objcMembers
public final class BridgewellConfig: NSObject {
    
    // MARK: - Public Properties
    
    /// Override for app ID (optional)
    /// If not provided, SDK will use App Store ID from Info.plist or bundle identifier
    @objc public var appIdOverride: String?
    
    /// Enable/disable SDK logging
    @objc public var loggingEnabled: Bool
    
    // MARK: - Initializers
    
    /// Initialize configuration with optional parameters
    /// - Parameters:
    ///   - appIdOverride: Custom app ID to use instead of automatic detection
    ///   - loggingEnabled: Whether to enable SDK logging (default: false)
    @objc public init(appIdOverride: String? = nil, loggingEnabled: Bool = false) {
        self.appIdOverride = appIdOverride
        self.loggingEnabled = loggingEnabled
        super.init()
    }
    
    // MARK: - NSObject Overrides
    
    public override var description: String {
        return "BridgewellConfig(appIdOverride: \(appIdOverride ?? "nil"), loggingEnabled: \(loggingEnabled))"
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? BridgewellConfig else { return false }
        return appIdOverride == other.appIdOverride && loggingEnabled == other.loggingEnabled
    }
    
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(appIdOverride)
        hasher.combine(loggingEnabled)
        return hasher.finalize()
    }
}
