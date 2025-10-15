//
//  BridgewellWebKitHandler.swift
//  BridgewellEventSDK
//
//  Created by Nguyễn Mai Quân on 19/9/25.
//

import Foundation
import WebKit

/**
 WebKit script handler for managing WebView data injection
 */
@objc internal class BridgewellWebKitHandler: NSObject, WKNavigationDelegate {
    
    // MARK: - Private Properties
    
    private weak var currentWebView: WKWebView?
    private var bwsMobile: BWSMobile?
    private var bwsGeo: BwsGeo?
    private var bwsDevice: BwsDevice?
    
    // State tracking for data injection timing
    private var isDataReady = false
    private var isWebViewReady = false
    
    private let logger = BridgewellLogger()

    // MARK: - Initialization

    override init() {
        super.init()
        logger.isEnabled = true
    }
    
    // MARK: - Public Methods
    
    /**
     Registers a WebView for async data injection
     - Parameter webView: The WKWebView to register
     */
    func registerWebViewAsync(_ webView: WKWebView?) {
        logger.log("BridgewellWebKitHandler.registerWebViewAsync called", level: .info)
        currentWebView = webView

        if #available(iOS 16.4, *) {
            #if DEBUG
            currentWebView?.isInspectable = true
            #endif
        }

        logger.log("Setting navigation delegate to self", level: .info)
        currentWebView?.navigationDelegate = self
        logger.log("Navigation delegate set, current delegate: \(String(describing: currentWebView?.navigationDelegate))", level: .info)

        logger.log("About to prepare data for WebView", level: .info)
        prepareDataForWebViewAsync()
        logger.log("Data preparation initiated", level: .info)
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        logger.log("BridgewellWebKitHandler.webView didFinish navigation called!", level: .info)
        logger.log("WebView finished loading", level: .info)

        isWebViewReady = true
        logger.log("WebView is ready, isDataReady: \(isDataReady)", level: .info)

        if isDataReady {
            logger.log("Data is ready, injecting immediately", level: .info)
            injectDataToWebView()
        } else {
            logger.log("Data not ready yet, waiting...", level: .info)
        }
    }
    
    // MARK: - Private Methods
    
    private func prepareDataForWebViewAsync() {
        logger.log("BridgewellWebKitHandler.prepareDataForWebViewAsync called", level: .info)
        getMobileData()
        logger.log("Mobile data prepared", level: .info)
        getDeviceData()
        logger.log("Device data prepared", level: .info)

        logger.log("About to get geo data", level: .info)
        getAppGeoData { [weak self] in
            guard let self = self else {
                self?.logger.log("Self is nil in geo data callback", level: .error)
                return
            }

            self.logger.log("Geo data callback executed", level: .info)
            self.logger.log("WebView data preparation completed", level: .info)

            self.isDataReady = true
            self.logger.log("Data is ready, isWebViewReady: \(self.isWebViewReady)", level: .info)

            if self.isWebViewReady {
                self.logger.log("WebView is ready, injecting data now", level: .info)
                self.injectDataToWebView()
            } else {
                self.logger.log("WebView not ready yet, waiting for navigation to finish", level: .info)
            }
        }
    }
    
    private func injectDataToWebView() {
        logger.log("BridgewellWebKitHandler.injectDataToWebView called", level: .info)
        logger.log("Injecting data to WebView...", level: .info)
        callOnSdkDataReadyWithAllData()
    }
    private func callOnSdkDataReadyWithAllData() {
        var scriptsToExecute: [String] = []
        
        // 1. Set mobile data
        if let mobile = bwsMobile {
            let escapedMobileJson = mobile.jsonString.replacingOccurrences(of: "'", with: "\\'")
            scriptsToExecute.append("try { window.bwsMobile = JSON.parse('\(escapedMobileJson)'); } catch(e) { window.bwsMobile = null; console.error('Failed to parse mobile data:', e); }")
        } else {
            scriptsToExecute.append("window.bwsMobile = null;")
        }

        // 2. Set geo data
        if let geo = bwsGeo {
            let escapedGeoJson = geo.jsonString.replacingOccurrences(of: "'", with: "\\'")
            scriptsToExecute.append("try { window.bwsGeo = JSON.parse('\(escapedGeoJson)'); } catch(e) { window.bwsGeo = null; console.error('Failed to parse geo data:', e); }")
        } else {
            scriptsToExecute.append("window.bwsGeo = null;")
        }

        // 3. Set device data
        if let device = bwsDevice {
            let escapedDeviceJson = device.jsonString.replacingOccurrences(of: "'", with: "\\'")
            scriptsToExecute.append("try { window.bwsDevice = JSON.parse('\(escapedDeviceJson)'); } catch(e) { window.bwsDevice = null; console.error('Failed to parse device data:', e); }")
        } else {
            scriptsToExecute.append("window.bwsDevice = null;")
        }

        // 4. Set SDK data
        let sdkVersion = "\(BridgewellEvent.sdkVersion)-\(BridgewellDataHelper.isInstalledAsCocoapods() ? "c" : "s")"
        scriptsToExecute.append("try { window.bwsdk = JSON.parse('{\"sdk_version\" : \"\(sdkVersion)\"}'); } catch(e) { window.bwsdk = null; console.error('Failed to parse SDK data:', e); }")

        // 5. Verify data is correctly set (debug logging)
        scriptsToExecute.append("""
        console.debug('=== BridgewellEventSDK Data Check ===');
        console.debug('window.bwsMobile:', typeof window.bwsMobile, window.bwsMobile);
        console.debug('window.bwsGeo:', typeof window.bwsGeo, window.bwsGeo);
        console.debug('window.bwsDevice:', typeof window.bwsDevice, window.bwsDevice);
        console.debug('window.bwsdk:', typeof window.bwsdk, window.bwsdk);
        console.debug('window.onSdkDataReady:', typeof window.onSdkDataReady);
        """)

        // 6. Call onSdkDataReady function
        scriptsToExecute.append("""
        console.debug('=== Calling onSdkDataReady ===');
        if (typeof window.onSdkDataReady === 'function') {
            console.debug('Calling onSdkDataReady directly...');
            try {
                window.onSdkDataReady(window.bwsMobile, window.bwsGeo, window.bwsDevice, window.bwsdk);
                console.debug('onSdkDataReady called successfully');
            } catch (e) {
                console.debug('Error calling onSdkDataReady:', e.message);
            }
        } else {
            console.debug('onSdkDataReady not found, scheduling retry...');
            setTimeout(function() {
                console.debug('Retry - checking onSdkDataReady...');
                if (typeof window.onSdkDataReady === 'function') {
                    console.debug('Found onSdkDataReady on retry, calling...');
                    window.onSdkDataReady(window.bwsMobile, window.bwsGeo, window.bwsDevice, window.bwsdk);
                    console.debug('onSdkDataReady called successfully on retry');
                } else {
                    console.debug('Still not found on retry');
                }
            }, 1000);
        }
        """)
        
        // Execute all scripts sequentially
        executeScriptsSequentially(scriptsToExecute, index: 0)
    }
    
    private func executeScriptsSequentially(_ scripts: [String], index: Int) {
        guard index < scripts.count else { return }

        let script = scripts[index]
        currentWebView?.evaluateJavaScript(script) { [weak self] result, error in
            if let error = error {
                self?.logger.log("Error executing script \(index): \(error.localizedDescription)", level: .error)
            } else {
                self?.logger.log("Script \(index) executed successfully", level: .debug)
            }

            self?.executeScriptsSequentially(scripts, index: index + 1)
        }
    }
    
    private func getMobileData() {
        bwsMobile = BridgewellDataHelper.getMobileData()
    }

    private func getAppGeoData(_ completion: @escaping () -> Void) {
        BridgewellDataHelper.getGeoInfo { [weak self] geo in
            self?.bwsGeo = geo
            completion()
        }
    }

    private func getDeviceData() {
        bwsDevice = BridgewellDataHelper.getDeviceInformation()
    }
}
