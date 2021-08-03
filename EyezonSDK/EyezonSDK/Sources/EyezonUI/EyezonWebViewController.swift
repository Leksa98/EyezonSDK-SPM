//
//  EyezonWebViewController.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import UIKit
import WebKit

class EyezonWebViewController: UIViewController {
    private lazy var eyezonWebView: WKWebView = {
        let webView = WKWebView()
        webView.uiDelegate = self
        return webView
    }()
    
    private let widgetUrl: String
    
    init(widgetUrl: String) {
        self.widgetUrl = widgetUrl
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        eyezonWebView.frame = view.frame
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(eyezonWebView)
        guard let url = URL(string: widgetUrl) else {
            return
        }
        let urlRequest = URLRequest(url: url)
        eyezonWebView.load(urlRequest)
        let source = "function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); } window.console.log = captureLog;"
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        eyezonWebView.configuration.userContentController.addUserScript(script)
        // register the bridge script that listens for the output
        eyezonWebView.configuration.userContentController.add(self, name: "logHandler")
    }
}

extension EyezonWebViewController: WKUIDelegate {
    func webViewDidClose(_ webView: WKWebView) {
        webView.evaluateJavaScript("javascript:eyeZon('leaveDialog')")
    }
}

extension EyezonWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
    }
}
