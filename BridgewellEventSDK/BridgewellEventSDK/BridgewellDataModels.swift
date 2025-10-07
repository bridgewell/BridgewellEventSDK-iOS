//
//  BridgewellDataModels.swift
//  BridgewellEventSDK
//
//  Created by Nguyễn Mai Quân on 19/9/25.
//

import Foundation

// MARK: - Mobile Information

/**
 Information for ad queries coming from mobile devices.
 A mobile device is either a smart phone or a tablet.
 This is present for ad queries both from mobile devices browsing the web and from mobile apps.
 */
struct BWSMobile: Codable {
    let isApp: Bool
    let appIdentifier: String?
    let advertisingID: String?
    
    enum CodingKeys: String, CodingKey {
        case isApp = "is_app"
        case appIdentifier = "app_id"
        case advertisingID = "idfa"
    }
}

// MARK: - Geographic Information

/**
 The user's approximate geographic location.
 All location information is IP geolocation-derived.
 The lat/lon fields may be a reference position (for example, centroid) for the IP geolocation-derived location that's also carried by the other fields (for example, a city), and accuracy will be the radius of a circle with the approximate area of that location. Location and its accuracy will be fuzzified as necessary to protect user privacy.
 */
struct BwsGeo: Codable {
    var lat: Double?
    var lon: Double?
    var country: String?
    var city: String?
    var zip: String?
    var accuracy: Double?
    let utcoffset: Int
}

// MARK: - Device Information

/**
 Information about the device.
 */
struct BwsDevice: Codable {
    let platform: String
    let brand: String?
    let model: String
    let osVersion: BwsOS?
    let carrier: String?
    let screenWidth: Int?
    let screenHeight: Int?
    let screenRatio: Int?
    var screenOrientation: BwsScreenOrientation = .UNKNOWN
    let hardwareVersion: String
    let limitAdTracking: Bool
    var appTrackingStatus: BwsAppTrackingStatus = .NOT_DETERMINED
    var connection: BwsConnectionType = .CONNECTION_UNKNOWN
    
    enum CodingKeys: String, CodingKey {
        case platform, brand, model
        case osVersion = "os_version"
        case carrier = "carrier"
        case screenWidth = "screen_width"
        case screenHeight = "screen_height"
        case screenRatio = "screen_pixel_ratio_millis"
        case screenOrientation = "screen_orientation"
        case hardwareVersion = "hardware_version"
        case limitAdTracking = "limit_ad_tracking"
        case appTrackingStatus = "app_tracking_authorization_status"
        case connection = "connection_type"
    }
}

// MARK: - OS Information

/**
 Information OS version of the platform
 For iPhone 3.3.1, major=3, minor=3 and micro=1
 */
struct BwsOS: Codable {
    let major: Int?
    let minor: Int?
    let micro: Int?
}

// MARK: - Enumerations

/**
 Screen orientation information
 */
enum BwsScreenOrientation: Int, Codable {
    case UNKNOWN = 0
    case PORTRAIT = 1
    case LANDSCAPE = 2
}

/**
 App tracking authorization status (iOS 14+)
 */
enum BwsAppTrackingStatus: Int, Codable {
    case NOT_DETERMINED = 0
    case RESTRICTED = 1
    case DENIED = 2
    case AUTHORIZED = 3
}

/**
 The type of network to which the user's device is connected.
 For 5G connection type, we send CELL_4G instead of CELL_5G
 */
enum BwsConnectionType: Int, Codable {
    case CONNECTION_UNKNOWN = 0
    case ETHERNET = 1
    case WIFI = 2
    case CELL_UNKNOWN = 3
    case CELL_2G = 4
    case CELL_3G = 5
    case CELL_4G = 6
    case CELL_5G = 7
}

// MARK: - JSON Encoding Extensions

/**
 Extension to provide JSON string conversion for Codable objects
 */
extension Encodable {
    subscript(key: String) -> Any? {
        return dictionary[key]
    }
    
    var dictionary: [String: Any] {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }
        return dictionary
    }
    
    var jsonString: String {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
              let jsonString = String(data: data, encoding: .utf8) else {
            return ""
        }
        return jsonString
    }
}
