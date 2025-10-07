//
//  BridgewellLogger.swift
//  BridgewellEventSDK
//
//  Created by Nguyễn Mai Quân on 19/9/25.
//

import Foundation
import os.log

/// Internal logger for BridgewellEventSDK
internal class BridgewellLogger {
    
    // MARK: - Log Levels
    
    enum LogLevel: String, CaseIterable {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        
        var osLogType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .info:
                return .info
            case .warning:
                return .default
            case .error:
                return .error
            }
        }
    }
    
    // MARK: - Properties
    
    var isEnabled: Bool = false
    private let subsystem = "com.bridgewell.eventsdk"
    private let category = "BridgewellEventSDK"
    private lazy var osLog = OSLog(subsystem: subsystem, category: category)
    
    // MARK: - Public Methods
    
    func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        guard isEnabled else { return }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "[\(level.rawValue)] \(fileName):\(line) \(function) - \(message)"
        
        if #available(iOS 12.0, *) {
            os_log("%{public}@", log: osLog, type: level.osLogType, logMessage)
        } else {
            // Fallback for iOS < 12.0
            print("[BridgewellEventSDK] \(logMessage)")
        }
    }
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
}
