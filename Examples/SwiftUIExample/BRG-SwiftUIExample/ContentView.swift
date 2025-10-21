//
//  ContentView.swift
//  BRG-SwiftUIExample
//
//  Created by Nguyễn Mai Quân on 2025-10-21.
//

import SwiftUI
import WebKit
import BridgewellEventSDK

struct ContentView: View {
    @State private var webViewContainer: WebViewContainer?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("BridgewellEventSDK")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("SwiftUI Example")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                
                // WebView
                if let container = webViewContainer {
                    WebViewRepresentable(webView: container.webView)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Initializing SDK...")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                }
                
                // Error message
                if let error = errorMessage {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text("Error")
                                .fontWeight(.bold)
                        }
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color(.systemRed).opacity(0.1))
                    .cornerRadius(8)
                    .padding()
                }
            }
        }
        .onAppear {
            setupSDK()
        }
    }
    
    private func setupSDK() {
        // Initialize SDK configuration
        let config = BridgewellConfig(
            appIdOverride: nil,
            loggingEnabled: true
        )
        
        // Initialize the SDK
        BridgewellEvent.shared.initialize(config: config)
        
        // Create WebView
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        
        // Register WebView with SDK for data injection
        BridgewellEvent.shared.registerContentWebViewWithAdInfo(webView)
        
        // Store the webView in a container
        webViewContainer = WebViewContainer(webView: webView)
        
        // Load content after a short delay to ensure SDK is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            loadWebContent()
        }
    }
    
    private func loadWebContent() {
        guard let webView = webViewContainer?.webView else { return }
        
        // Try to load local HTML file first
//        if let path = Bundle.main.path(forResource: "test-device-injection", ofType: "html"),
//           let htmlString = try? String(contentsOfFile: path, encoding: .utf8) {
//            let baseURL = URL(fileURLWithPath: path)
//            webView.loadHTMLString(htmlString, baseURL: baseURL)
//        } else {
            // Fallback to remote URL
            if let url = URL(string: "https://img.scupio.com/cat/webview-test.html") {
                webView.load(URLRequest(url: url))
            } else {
                errorMessage = "Failed to load web content"
            }
//        }
    }
}

// MARK: - WebView Container
class WebViewContainer: NSObject {
    let webView: WKWebView
    
    init(webView: WKWebView) {
        self.webView = webView
        super.init()
    }
}

// MARK: - WebView Representable
struct WebViewRepresentable: UIViewRepresentable {
    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update logic if needed
    }
}

#Preview {
    ContentView()
}

