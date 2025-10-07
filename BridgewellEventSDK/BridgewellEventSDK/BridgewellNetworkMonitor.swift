//
//  BridgewellNetworkMonitor.swift
//  BridgewellEventSDK
//
//  Created by Bridgewell SDK on 2025.
//

import Foundation
import Network
import CoreTelephony

/**
 Network connection monitoring for BridgewellEventSDK
 */
class BridgewellNetworkMonitor {
    
    // MARK: - Singleton
    
    static let shared = BridgewellNetworkMonitor()
    
    // MARK: - Properties
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "BridgewellNetworkMonitor")
    
    private(set) var connectionType: BwsConnectionType = .CONNECTION_UNKNOWN
    
    // MARK: - Initialization
    
    private init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Public Methods
    
    /**
     Gets current connection type
     */
    func getCurrentConnectionType() -> BwsConnectionType {
        return connectionType
    }
    
    // MARK: - Private Methods
    
    /**
     Starts network monitoring
     */
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            if path.status == .satisfied {
                if path.usesInterfaceType(.wifi) {
                    self.connectionType = .WIFI
                } else if path.usesInterfaceType(.cellular) {
                    self.getCellularConnectionType()
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self.connectionType = .ETHERNET
                } else {
                    self.connectionType = .CONNECTION_UNKNOWN
                }
            } else {
                self.connectionType = .CONNECTION_UNKNOWN
            }
        }
        
        monitor.start(queue: queue)
    }
    
    /**
     Stops network monitoring
     */
    private func stopMonitoring() {
        monitor.cancel()
    }
    
    /**
     Determines cellular connection type (2G, 3G, 4G, 5G)
     */
    private func getCellularConnectionType() {
        let networkInfo = CTTelephonyNetworkInfo()
        
        if let currentRadioAccessTechnology = networkInfo.serviceCurrentRadioAccessTechnology {
            // Get the first available radio access technology
            if let radioTech = currentRadioAccessTechnology.values.first {
                connectionType = mapRadioTechnologyToConnectionType(radioTech)
            } else {
                connectionType = .CELL_UNKNOWN
            }
        } else {
            connectionType = .CELL_UNKNOWN
        }
    }
    
    /**
     Maps radio access technology to connection type
     */
    private func mapRadioTechnologyToConnectionType(_ radioTech: String) -> BwsConnectionType {
        switch radioTech {
        // 2G Technologies
        case CTRadioAccessTechnologyGPRS,
             CTRadioAccessTechnologyEdge:
            return .CELL_2G
            
        // 3G Technologies
        case CTRadioAccessTechnologyWCDMA,
             CTRadioAccessTechnologyHSDPA,
             CTRadioAccessTechnologyHSUPA,
             CTRadioAccessTechnologyCDMA1x,
             CTRadioAccessTechnologyCDMAEVDORev0,
             CTRadioAccessTechnologyCDMAEVDORevA,
             CTRadioAccessTechnologyCDMAEVDORevB:
            return .CELL_3G
            
        // 4G Technologies
        case CTRadioAccessTechnologyLTE:
            return .CELL_4G
            
        // 5G Technologies
        default:
            if #available(iOS 14.1, *) {
                switch radioTech {
                case CTRadioAccessTechnologyNRNSA,
                     CTRadioAccessTechnologyNR:
                    return .CELL_5G
                default:
                    return .CELL_UNKNOWN
                }
            } else {
                return .CELL_UNKNOWN
            }
        }
    }
}
