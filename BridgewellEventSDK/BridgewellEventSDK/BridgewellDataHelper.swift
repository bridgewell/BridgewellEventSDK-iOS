//
//  BridgewellDataHelper.swift
//  BridgewellEventSDK
//
//  Created by Nguyễn Mai Quân on 19/9/25.
//

import Foundation
import CoreTelephony
import AppTrackingTransparency
import AdSupport
#if canImport(UIKit)
import UIKit
#endif
import CoreLocation
import Network

// MARK: - Data Collection Helper

/**
 Helper class for collecting device, mobile, and geographic information
 */
class BridgewellDataHelper {
    
    // MARK: - Mobile Data
    
    /**
     Creates mobile information object
     */
    static func getMobileData() -> BWSMobile {
        return BWSMobile(
            isApp: true,
            appIdentifier: Bundle.main.bundleIdentifier,
            advertisingID: getIDFA()
        )
    }
    
    /**
     Gets IDFA with proper ATT compliance
     */
    static func getIDFA() -> String? {
        // Check whether advertising tracking is enabled
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus != .authorized {
                return nil
            }
        } else {
            if !ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                return nil
            }
        }
        
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    // MARK: - Device Data
    
    /**
     Creates device information object
     */
    static func getDeviceInformation() -> BwsDevice {
        #if canImport(UIKit)
        let screen = UIScreen.main
        let screenBounds = screen.bounds
        let screenScale = screen.scale

        let screenWidthInPixels = Int(screenBounds.width * screenScale)
        let screenHeightInPixels = Int(screenBounds.height * screenScale)
        let ratioInMillis = Int((screenBounds.height / screenBounds.width) * 1000)
        #else
        // Default values for non-iOS platforms
        let screenWidthInPixels = 375
        let screenHeightInPixels = 667
        let ratioInMillis = Int((667.0 / 375.0) * 1000) // Default iPhone ratio
        #endif
        
        let limitAdTracking: Bool
        if #available(iOS 14, *) {
            limitAdTracking = ATTrackingManager.trackingAuthorizationStatus != .authorized
        } else {
            limitAdTracking = !ASIdentifierManager.shared().isAdvertisingTrackingEnabled
        }
        
        return BwsDevice(
            platform: "iOS",
            brand: "Apple",
            model: getDeviceModel(),
            osVersion: getOSVersionComponents(),
            carrier: getCarrierName(),
            screenWidth: screenWidthInPixels,
            screenHeight: screenHeightInPixels,
            screenRatio: ratioInMillis,
            screenOrientation: getDeviceCurrentOrientation(),
            hardwareVersion: getDeviceModel(),
            limitAdTracking: limitAdTracking,
            appTrackingStatus: getAppTrackingStatus(),
            connection: getConnectionType()
        )
    }
    
    /**
     Gets device model identifier using sysctlbyname (more accurate)
     */
    static func getDeviceModel() -> String {
        var size: Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        let modelIdentifier = String(cString: machine)
        return modelIdentifier
    }
    
    /**
     Gets OS version components
     */
    static func getOSVersionComponents() -> BwsOS? {
        #if canImport(UIKit)
        let systemVersion = UIDevice.current.systemVersion
        #else
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersionString
        #endif
        let versionComponents = systemVersion.split(separator: ".").compactMap { Int($0) }
        return BwsOS(
            major: versionComponents.count > 0 ? versionComponents[0] : nil,
            minor: versionComponents.count > 1 ? versionComponents[1] : nil,
            micro: versionComponents.count > 2 ? versionComponents[2] : nil
        )
    }
    
    /**
     Gets carrier name
     */
    class func getCarrierName() -> String? {
        let networkInfo = CTTelephonyNetworkInfo()
        var carrierNames: [String] = []

        if let providers = networkInfo.serviceSubscriberCellularProviders {
            for (_, carrier) in providers {
                if let carrierName = carrier.carrierName {
                    carrierNames.append(carrierName)
                }
            }
        }
        let carrierName: String = carrierNames.first != "--" ? carrierNames.first ?? "" : ""
        if let latinText = carrierName.applyingTransform(.toLatin, reverse: false)?
            .applyingTransform(.stripCombiningMarks, reverse: false) {
            return latinText
        }
        return nil
    }

    /**
     Gets current device orientation
     */
    static func getDeviceCurrentOrientation() -> BwsScreenOrientation {
        #if canImport(UIKit)
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portrait, .portraitUpsideDown:
            return .PORTRAIT
        case .landscapeLeft, .landscapeRight:
            return .LANDSCAPE
        default:
            return .UNKNOWN
        }
        #else
        // Default to portrait for non-iOS platforms
        return .PORTRAIT
        #endif
    }
    
    /**
     Gets app tracking authorization status
     */
    static func getAppTrackingStatus() -> BwsAppTrackingStatus {
        if #available(iOS 14, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .notDetermined:
                return .NOT_DETERMINED
            case .restricted:
                return .RESTRICTED
            case .denied:
                return .DENIED
            case .authorized:
                return .AUTHORIZED
            @unknown default:
                return .NOT_DETERMINED
            }
        } else {
            return ASIdentifierManager.shared().isAdvertisingTrackingEnabled ? .AUTHORIZED : .DENIED
        }
    }
    
    /**
     Gets connection type using network monitoring
     */
    static func getConnectionType() -> BwsConnectionType {
        return BridgewellNetworkMonitor.shared.getCurrentConnectionType()
    }
    
    // MARK: - Geographic Data
    
    /**
     Gets UTC offset in minutes
     */
    static func getUTCOffsetInMinutes() -> Int {
        let currentTimeZone = TimeZone.current
        let secondsFromGMT = currentTimeZone.secondsFromGMT()
        return secondsFromGMT / 60
    }
    
    /**
     Gets geographic information with location services and reverse geocoding
     */
    static func getGeoInfo(_ completion: @escaping (BwsGeo?) -> Void) {
        BridgewellLocationManager.shared.getGeoInfo(completion)
    }
    
    /**
     Checks if SDK is installed via CocoaPods
     */
    static func isInstalledAsCocoapods() -> Bool {
        // Check if the framework is embedded vs linked
        return Bundle(identifier: "org.cocoapods.BridgewellEventSDK") != nil
    }
}

// MARK: - Array Extension

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
