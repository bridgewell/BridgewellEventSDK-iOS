//
//  ViewController.swift
//  BRG-SwiftExample
//
//  Created by Nguyễn Mai Quân on 23/9/25.
//

import UIKit
import WebKit
import BridgewellEventSDK

class ViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!

	override func viewDidLoad() {
		super.viewDidLoad()

        let config = BridgewellConfig(
            appIdOverride: nil,
            loggingEnabled: true
        )
        BridgewellEvent.shared.initialize(config: config)

        BridgewellEvent.shared.registerContentWebViewWithAdInfo(webView!)
	}

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.handleLoadRemoteWebview()
        }
    }

    private func handleLoadWebview() {
        if let path = Bundle.main.path(forResource: "test-device-injection", ofType: "html"),
           let htmlString = try? String(contentsOfFile: path, encoding: .utf8) {
            let baseURL = URL(fileURLWithPath: path)
            webView.loadHTMLString(htmlString, baseURL: baseURL)
        } else {
            if let url = URL(string: "https://img.scupio.com/cat/webview-test.html") {
                webView.load(URLRequest(url: url))
            }
        }
    }

    private func handleLoadRemoteWebview() {
        if let url = URL(string: "https://img.scupio.com/cat/webview-test.html") {
            webView.load(URLRequest(url: url))
        }
    }
}

