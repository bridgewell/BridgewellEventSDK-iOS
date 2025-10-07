//
//  BridgewellLocationManager.swift
//  BridgewellEventSDK
//
//  Created by Bridgewell SDK on 2025.
//

import Foundation
import CoreLocation

/**
 Location manager for BridgewellEventSDK
 Handles location services and reverse geocoding
 */
class BridgewellLocationManager: NSObject {
    
    // MARK: - Singleton
    
    static let shared = BridgewellLocationManager()
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    private var currentLocation: CLLocation?
    private var locationEnabled = true
    private var pendingGeoCompletions: [(id: UUID, completion: (BwsGeo?) -> Void, timer: Timer)] = []

    // MARK: - Configuration Constants

    /// Timeout for waiting for location updates (in seconds)
    private static let LOCATION_TIMEOUT: TimeInterval = 10.0
    
    // MARK: - Public Properties
    
    var coordinates: CLLocationCoordinate2D {
        return currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    var horizontalAccuracy: CLLocationAccuracy {
        return currentLocation?.horizontalAccuracy ?? 0
    }
    
    var coordinatesAreValid: Bool {
        guard let location = currentLocation else { return false }
        return location.horizontalAccuracy > 0 && location.horizontalAccuracy < 1000
    }
    
    var isLocationEnabled: Bool {
        get { return locationEnabled }
        set {
            locationEnabled = newValue
            if newValue {
                requestLocationPermission()
            } else {
                stopLocationUpdates()
            }
        }
    }
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        setupLocationManager()
        // Start location services by default
        requestLocationPermission()
    }
    
    // MARK: - Public Methods
    
    /**
     Gets geographic information with reverse geocoding
     */
    func getGeoInfo(_ completion: @escaping (BwsGeo?) -> Void) {
        let geo = BwsGeo(utcoffset: getUTCOffsetInMinutes())

        // If location is disabled, return basic geo info
        guard locationEnabled else {
            completion(geo)
            return
        }

        // If we have valid coordinates, process immediately
        if coordinatesAreValid {
            processGeoInfo(geo: geo, completion: completion)
            return
        }

        // If location is not yet available, queue the completion and wait for location update
        let requestId = UUID()
        let timer = Timer.scheduledTimer(withTimeInterval: Self.LOCATION_TIMEOUT, repeats: false) { [weak self] _ in
            self?.handleLocationTimeout(for: requestId)
        }

        pendingGeoCompletions.append((id: requestId, completion: completion, timer: timer))

        // Ensure location updates are started
        requestLocationPermission()
    }

    /**
     Processes geo info with current location data
     */
    private func processGeoInfo(geo: BwsGeo, completion: @escaping (BwsGeo?) -> Void) {
        var updatedGeo = geo

        let coordinate = coordinates
        updatedGeo.accuracy = horizontalAccuracy
        updatedGeo.lat = coordinate.latitude
        updatedGeo.lon = coordinate.longitude

        // Perform reverse geocoding
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if error != nil {
                completion(updatedGeo)
                return
            }

            guard let placemark = placemarks?.first else {
                completion(updatedGeo)
                return
            }

            // Extract location information
            updatedGeo.country = self.getCountryCode(from: placemark.isoCountryCode)
            updatedGeo.city = placemark.locality ?? ""
            updatedGeo.zip = placemark.postalCode ?? ""

            completion(updatedGeo)
        }
    }

    /**
     Handles timeout for location requests
     */
    private func handleLocationTimeout(for requestId: UUID) {
        // Find and remove the specific completion from pending list
        if let index = pendingGeoCompletions.firstIndex(where: { $0.id == requestId }) {
            let item = pendingGeoCompletions.remove(at: index)
            item.timer.invalidate()

            // Return basic geo info with current location (if any) or just timezone
            let geo = BwsGeo(utcoffset: getUTCOffsetInMinutes())
            if coordinatesAreValid {
                processGeoInfo(geo: geo, completion: item.completion)
            } else {
                item.completion(geo)
            }
        }
    }
    
    // MARK: - Private Methods
    
    /**
     Sets up location manager
     */
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Update every 100 meters
    }
    
    /**
     Requests location permission - relies on delegate callback for status handling
     */
    private func requestLocationPermission() {
        // Always request permission - the delegate will handle the response
        if #available(iOS 8.0, *) {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    /**
     Starts location updates - dispatched to background queue to avoid UI blocking
     */
    private func startLocationUpdates() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.locationManager.startUpdatingLocation()
        }
    }
    
    /**
     Stops location updates - dispatched to background queue to avoid UI blocking
     */
    private func stopLocationUpdates() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.locationManager.stopUpdatingLocation()
        }
    }
    
    /**
     Gets UTC offset in minutes
     */
    private func getUTCOffsetInMinutes() -> Int {
        let currentTimeZone = TimeZone.current
        let secondsFromGMT = currentTimeZone.secondsFromGMT()
        return secondsFromGMT / 60
    }
    
    /**
     Converts ISO country code to 3-letter country code
     */
    private func getCountryCode(from isoCode: String?) -> String? {
        guard let isoCode = isoCode else { return nil }
        
        // Simple mapping for common countries
        // In a full implementation, you would use a comprehensive mapping
        let countryMapping: [String: String] = [
            "US": "USA",
            "CA": "CAN",
            "MX": "MEX",
            "GB": "GBR",
            "FR": "FRA",
            "DE": "DEU",
            "JP": "JPN",
            "CN": "CHN",
            "IN": "IND",
            "BR": "BRA",
            "AU": "AUS",
            "RU": "RUS",
            "IT": "ITA",
            "ES": "ESP",
            "KR": "KOR",
            "NL": "NLD",
            "SE": "SWE",
            "NO": "NOR",
            "DK": "DNK",
            "FI": "FIN"
        ]
        
        return countryMapping[isoCode] ?? isoCode
    }
}

// MARK: - CLLocationManagerDelegate

extension BridgewellLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location

        // Process any pending geo info requests
        if coordinatesAreValid && !pendingGeoCompletions.isEmpty {
            let items = pendingGeoCompletions
            pendingGeoCompletions.removeAll()

            for item in items {
                item.timer.invalidate()
                let geo = BwsGeo(utcoffset: getUTCOffsetInMinutes())
                processGeoInfo(geo: geo, completion: item.completion)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Location update failed - handled silently
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if locationEnabled {
                startLocationUpdates()
            }
        case .denied, .restricted:
            stopLocationUpdates()
            currentLocation = nil

            // Complete pending requests with basic geo info (no location data)
            if !pendingGeoCompletions.isEmpty {
                let items = pendingGeoCompletions
                pendingGeoCompletions.removeAll()

                for item in items {
                    item.timer.invalidate()
                    let geo = BwsGeo(utcoffset: getUTCOffsetInMinutes())
                    item.completion(geo)
                }
            }
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}
