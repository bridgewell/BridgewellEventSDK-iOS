Pod::Spec.new do |spec|
  spec.name         = "BridgewellEventSDK"
  spec.version      = "0.1.0"
  spec.summary      = "iOS SDK providing event/bridge layer for WebView integration"
  spec.description  = <<-DESC
    BridgewellEventSDK is an iOS SDK that provides an event/bridge layer for iOS applications. 
    It offers a secure, asynchronous mechanism to inject app and device information into in-app 
    WebViews via the window.bwsMobile JavaScript object.
    
    Key Features:
    - Easy integration with Swift Package Manager and CocoaPods
    - Compatible with both Swift and Objective-C projects
    - WebView integration with seamless data injection
    - Privacy compliant with ATT consent handling
    - Asynchronous, non-blocking operations
    - Comprehensive test coverage
  DESC

  spec.homepage     = "https://github.com/bridgewell/iOS-BridgewellEventSDK"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Bridgewell" => "support@bridgewell.com" }
  spec.source       = { :git => "https://github.com/bridgewell/iOS-BridgewellEventSDK.git", :tag => "v#{spec.version}" }

  spec.ios.deployment_target = "12.0"
  spec.swift_version = "5.7"

  spec.source_files = "BridgewellEventSDK/BridgewellEventSDK/**/*.{swift,h,m}"
  spec.public_header_files = "BridgewellEventSDK/BridgewellEventSDK/**/*.h"
  
  spec.frameworks = "Foundation", "WebKit", "AdSupport", "AppTrackingTransparency"
  
  spec.requires_arc = true
  
  # Podspec metadata
  spec.cocoapods_version = ">= 1.10.0"
  
  # Documentation
  spec.documentation_url = "https://bridgewell.github.io/iOS-BridgewellEventSDK/"
  
  # Social media
  spec.social_media_url = "https://twitter.com/bridgewell"
  
  # Screenshots (optional)
  # spec.screenshots = ["https://example.com/screenshot1.png"]
  
  # Subspecs (if needed in the future)
  # spec.subspec 'Core' do |core|
  #   core.source_files = 'BridgewellEventSDK/BridgewellEventSDK/Core/**/*.{swift,h,m}'
  # end
end
