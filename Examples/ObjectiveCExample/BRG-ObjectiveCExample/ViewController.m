//
//  ViewController.m
//  BRG-ObjectiveCExample
//
//  Created by Nguyễn Mai Quân on 23/9/25.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <BridgewellEventSDK/BridgewellEventSDK-Swift.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Initialize the SDK
    BridgewellConfig *config = [[BridgewellConfig alloc] initWithAppIdOverride:nil
                                                               loggingEnabled:YES];
    [[BridgewellEvent shared] initializeWithConfig:config];

    // Load your web content
    NSURL *url = [NSURL URLWithString:@"https://img.scupio.com/cat/webview-test.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];

    // Register WebView for comprehensive data injection (includes device info)
    // This method will inject full device data including BwsDevice, BwsGeo, BwsMobile, etc.
    // Location services are enabled by default in the enhanced SDK
    [[BridgewellEvent shared] registerContentWebViewWithAdInfo:self.webView];
}


@end
