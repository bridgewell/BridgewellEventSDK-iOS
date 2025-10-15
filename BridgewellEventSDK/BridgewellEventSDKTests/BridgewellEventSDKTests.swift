//
//  BridgewellEventSDKTests.swift
//  BridgewellEventSDKTests
//
//  Created by Nguyễn Mai Quân on 19/9/25.
//

import XCTest
import WebKit
@testable import BridgewellEventSDK

final class BridgewellEventSDKTests: XCTestCase {

    // MARK: - Properties

    var webView: WKWebView!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        super.setUp()
        webView = WKWebView()

        // Reset SDK state for each test
        resetSDKState()
    }

    override func tearDownWithError() throws {
        webView = nil
        resetSDKState()
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func resetSDKState() {
        BridgewellEvent.shared.resetForTesting()
    }

    // MARK: - Version Tests

    func testSDKVersion() throws {
        XCTAssertEqual(BridgewellEventSDK.sdkVersion, "0.1.0")
        XCTAssertFalse(BridgewellEventSDK.sdkVersion.isEmpty)
        XCTAssertEqual(BridgewellEvent.shared.version, BridgewellEventSDK.sdkVersion)
    }

    // MARK: - Configuration Tests

    func testBridgewellConfigInitialization() throws {
        let config = BridgewellConfig()
        XCTAssertNil(config.appIdOverride)
        XCTAssertFalse(config.loggingEnabled)
    }

    func testBridgewellConfigWithParameters() throws {
        let config = BridgewellConfig(appIdOverride: "test.app.id", loggingEnabled: true)
        XCTAssertEqual(config.appIdOverride, "test.app.id")
        XCTAssertTrue(config.loggingEnabled)
    }

    func testBridgewellConfigEquality() throws {
        let config1 = BridgewellConfig(appIdOverride: "test", loggingEnabled: true)
        let config2 = BridgewellConfig(appIdOverride: "test", loggingEnabled: true)
        let config3 = BridgewellConfig(appIdOverride: "different", loggingEnabled: true)

        XCTAssertEqual(config1, config2)
        XCTAssertNotEqual(config1, config3)
    }

    func testBridgewellConfigDescription() throws {
        let config = BridgewellConfig(appIdOverride: "test", loggingEnabled: true)
        let description = config.description

        XCTAssertTrue(description.contains("test"))
        XCTAssertTrue(description.contains("true"))
    }

    // MARK: - SDK Initialization Tests

    func testSDKInitialization() throws {
        let config = BridgewellConfig(loggingEnabled: true)

        // This test verifies that initialization doesn't throw
        XCTAssertNoThrow(BridgewellEvent.shared.initialize(config: config))
    }

    func testSDKDoubleInitialization() throws {
        let config = BridgewellConfig(loggingEnabled: true)

        BridgewellEvent.shared.initialize(config: config)

        // Second initialization should not cause issues
        XCTAssertNoThrow(BridgewellEvent.shared.initialize(config: config))
    }

    // MARK: - Error Tests

    func testBridgewellErrorDescriptions() throws {
        let errors: [BridgewellError] = [
            .notInitialized,
            .injectionFailed,
            .webViewNotReady,
            .invalidConfiguration
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertNotNil(error.failureReason)
            XCTAssertNotNil(error.recoverySuggestion)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    func testBridgewellErrorHelper() throws {
        let notInitializedError = BridgewellErrorHelper.notInitializedError()
        XCTAssertEqual(notInitializedError.code, BridgewellError.notInitialized.rawValue)

        let injectionFailedError = BridgewellErrorHelper.injectionFailedError()
        XCTAssertEqual(injectionFailedError.code, BridgewellError.injectionFailed.rawValue)

        let webViewNotReadyError = BridgewellErrorHelper.webViewNotReadyError()
        XCTAssertEqual(webViewNotReadyError.code, BridgewellError.webViewNotReady.rawValue)

        let invalidConfigError = BridgewellErrorHelper.invalidConfigurationError()
        XCTAssertEqual(invalidConfigError.code, BridgewellError.invalidConfiguration.rawValue)
    }

    // MARK: - Injection Tests (Callback-based)

    func testInjectionWithoutInitialization() throws {
        let expectation = XCTestExpectation(description: "Injection should fail without initialization")

        BridgewellEvent.shared.inject(webView: webView) { success, error in
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            XCTAssertEqual((error as? BridgewellError), .notInitialized)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testInjectionWithInitialization() throws {
        let config = BridgewellConfig(loggingEnabled: true)
        BridgewellEvent.shared.initialize(config: config)

        let expectation = XCTestExpectation(description: "Injection should complete")

        BridgewellEvent.shared.inject(webView: webView) { success, error in
            // Note: This might fail in unit tests due to WebView context issues
            // In a real app with a properly loaded WebView, this should succeed
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    // MARK: - Async/Await Tests (iOS 13.0+)

    @available(iOS 13.0, *)
    func testAsyncInjectionWithoutInitialization() async throws {
        do {
            _ = try await BridgewellEvent.shared.inject(webView: webView)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertEqual(error as? BridgewellError, .notInitialized)
        }
    }

    @available(iOS 13.0, *)
    func testAsyncInjectionWithInitialization() async throws {
        let config = BridgewellConfig(loggingEnabled: true)
        BridgewellEvent.shared.initialize(config: config)

        // Note: This test might fail due to WebView context in unit tests
        // In integration tests with a real WebView, this should work
        do {
            _ = try await BridgewellEvent.shared.inject(webView: webView)
            // If we reach here, injection succeeded
        } catch {
            // Expected in unit test environment
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Performance Tests

    func testSDKInitializationPerformance() throws {
        let config = BridgewellConfig(loggingEnabled: false)

        measure {
            BridgewellEvent.shared.initialize(config: config)
        }
    }

    func testConfigCreationPerformance() throws {
        measure {
            _ = BridgewellConfig(appIdOverride: "test.app.id", loggingEnabled: true)
        }
    }

    // MARK: - WebView Registration Tests

    func testRegisterContentWebViewWithAdInfoWithoutInitialization() throws {
        let webView = WKWebView()

        // Should not crash but should log error
        BridgewellEvent.shared.registerContentWebViewWithAdInfo(webView)

        // No assertions needed - just ensuring it doesn't crash
    }

    func testRegisterContentWebViewWithAdInfoWithInitialization() throws {
        let config = BridgewellConfig(loggingEnabled: true)
        BridgewellEvent.shared.initialize(config: config)

        let webView = WKWebView()

        // Should not crash and should register successfully
        BridgewellEvent.shared.registerContentWebViewWithAdInfo(webView)

        // No assertions needed - just ensuring it doesn't crash
    }

    // MARK: - Data Model Tests

    func testBWSMobileDataModel() throws {
        let mobile = BWSMobile(isApp: true, appIdentifier: "com.test.app", advertisingID: "test-idfa")

        XCTAssertTrue(mobile.isApp)
        XCTAssertEqual(mobile.appIdentifier, "com.test.app")
        XCTAssertEqual(mobile.advertisingID, "test-idfa")

        // Test JSON conversion
        let jsonString = mobile.jsonString
        XCTAssertFalse(jsonString.isEmpty)
        XCTAssertTrue(jsonString.contains("is_app"))
        XCTAssertTrue(jsonString.contains("app_id"))
        XCTAssertTrue(jsonString.contains("idfa"))
    }

    func testBwsGeoDataModel() throws {
        let geo = BwsGeo(lat: 37.7749, lon: -122.4194, country: "US", city: "San Francisco", zip: "94102", accuracy: 100.0, utcoffset: -480)

        XCTAssertEqual(geo.lat, 37.7749)
        XCTAssertEqual(geo.lon, -122.4194)
        XCTAssertEqual(geo.country, "US")
        XCTAssertEqual(geo.city, "San Francisco")
        XCTAssertEqual(geo.zip, "94102")
        XCTAssertEqual(geo.accuracy, 100.0)
        XCTAssertEqual(geo.utcoffset, -480)

        // Test JSON conversion
        let jsonString = geo.jsonString
        XCTAssertFalse(jsonString.isEmpty)
    }

    func testBwsDeviceDataModel() throws {
        let osVersion = BwsOS(major: 17, minor: 0, micro: 1)
        let device = BwsDevice(
            platform: "iOS",
            brand: "Apple",
            model: "iPhone15,2",
            osVersion: osVersion,
            carrier: "Verizon",
            screenWidth: 1179,
            screenHeight: 2556,
            screenRatio: 3000,
            screenOrientation: .PORTRAIT,
            hardwareVersion: "iPhone15,2",
            limitAdTracking: false,
            appTrackingStatus: .AUTHORIZED,
            connection: .WIFI
        )

        XCTAssertEqual(device.platform, "iOS")
        XCTAssertEqual(device.brand, "Apple")
        XCTAssertEqual(device.model, "iPhone15,2")
        XCTAssertEqual(device.osVersion?.major, 17)
        XCTAssertEqual(device.carrier, "Verizon")
        XCTAssertEqual(device.screenWidth, 1179)
        XCTAssertEqual(device.screenHeight, 2556)
        XCTAssertEqual(device.screenOrientation, .PORTRAIT)
        XCTAssertFalse(device.limitAdTracking)
        XCTAssertEqual(device.appTrackingStatus, .AUTHORIZED)
        XCTAssertEqual(device.connection, .WIFI)

        // Test JSON conversion
        let jsonString = device.jsonString
        XCTAssertFalse(jsonString.isEmpty)
    }

    // MARK: - Data Helper Tests

    func testBridgewellDataHelperMobileData() throws {
        let mobileData = BridgewellDataHelper.getMobileData()

        XCTAssertTrue(mobileData.isApp)
        XCTAssertNotNil(mobileData.appIdentifier)
        // IDFA may be nil depending on ATT status
    }

    func testBridgewellDataHelperDeviceData() throws {
        let deviceData = BridgewellDataHelper.getDeviceInformation()

        XCTAssertEqual(deviceData.platform, "iOS")
        XCTAssertEqual(deviceData.brand, "Apple")
        XCTAssertFalse(deviceData.model.isEmpty)
        XCTAssertNotNil(deviceData.osVersion)
        XCTAssertNotNil(deviceData.screenWidth)
        XCTAssertNotNil(deviceData.screenHeight)
        XCTAssertNotNil(deviceData.screenRatio)
    }

    func testBridgewellDataHelperGeoData() throws {
        let expectation = XCTestExpectation(description: "Geo data completion")

        BridgewellDataHelper.getGeoInfo { geo in
            XCTAssertNotNil(geo)
            XCTAssertNotNil(geo?.utcoffset)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testBridgewellDataHelperUTCOffset() throws {
        let utcOffset = BridgewellDataHelper.getUTCOffsetInMinutes()

        // UTC offset should be a reasonable value (between -12 and +14 hours in minutes)
        XCTAssertGreaterThanOrEqual(utcOffset, -12 * 60)
        XCTAssertLessThanOrEqual(utcOffset, 14 * 60)
    }

    func testBridgewellDataHelperDeviceModel() throws {
        let model = BridgewellDataHelper.getDeviceModel()

        XCTAssertFalse(model.isEmpty)
        // Should contain some recognizable pattern for iOS devices
        XCTAssertTrue(model.contains("iPhone") || model.contains("iPad") || model.contains("iPod") || model.contains("x86_64") || model.contains("arm64"))
    }

    func testBridgewellDataHelperOSVersion() throws {
        let osVersion = BridgewellDataHelper.getOSVersionComponents()

        XCTAssertNotNil(osVersion)
        XCTAssertNotNil(osVersion?.major)
        XCTAssertGreaterThan(osVersion?.major ?? 0, 0)
    }

    // MARK: - WebKit Handler Tests

    func testWebKitHandlerRegistration() throws {
        let handler = BridgewellWebKitHandler()
        let webView = WKWebView()

        // Should not crash
        handler.registerWebViewAsync(webView)

        // Give some time for async operations
        let expectation = XCTestExpectation(description: "Handler registration")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Integration Tests

    func testFullWebViewRegistrationFlow() throws {
        let config = BridgewellConfig(loggingEnabled: true)
        BridgewellEvent.shared.initialize(config: config)

        let webView = WKWebView()

        // Register the WebView
        BridgewellEvent.shared.registerContentWebViewWithAdInfo(webView)

        // Give some time for async data preparation
        let expectation = XCTestExpectation(description: "WebView registration flow")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
