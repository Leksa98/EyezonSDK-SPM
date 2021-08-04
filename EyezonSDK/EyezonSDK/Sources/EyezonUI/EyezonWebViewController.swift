//
//  EyezonWebViewController.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import UIKit
import WebKit

final class EyezonWebViewController: UIViewController {
    
    // MARK: - Private properties
    private lazy var eyezonWebView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        return webView
    }()
    private let widgetUrl: String
    private var observable: NSKeyValueObservation?
    private weak var broadcastReceiver: EyezonBroadcastReceiver?

    // MARK: - Public properties
    var presenter: EyezonWebViewPresenter!

    // MARK: - Lifecycle
    deinit {
        print(#function)
    }
    
    init(
        widgetUrl: String,
        broadcastReceiver: EyezonBroadcastReceiver?
    ) {
        self.widgetUrl = widgetUrl
        self.broadcastReceiver = broadcastReceiver
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(eyezonWebView)
        guard let url = URL(string: widgetUrl) else {
            return
        }
        let urlRequest = URLRequest(url: url)
        eyezonWebView.load(urlRequest)
        injectingScripts()
        let preferences = WKWebpagePreferences()
        preferences.preferredContentMode = .mobile
        preferences.allowsContentJavaScript = true
        eyezonWebView.configuration.defaultWebpagePreferences = preferences
        constraintView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        observable = eyezonWebView.observe(\.title) { [weak self] webView, _ in
            self?.navigationItem.title = webView.title
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        observable?.invalidate()
        observable = nil
        eyezonWebView.evaluateJavaScript("javascript:eyeZon('leaveDialog')")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFromParent()
    }
    
    // MARK: - Private methods
    private func constraintView() {
        let constraints = [
            eyezonWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            eyezonWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            eyezonWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            eyezonWebView.topAnchor.constraint(equalTo: view.topAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func injectingScripts() {
        /// For listening console events
        let source = "function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); } window.console.log = captureLog;"
        let script = WKUserScript(
            source: source,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        
        /// For disabling zoom-in
        /// https://developer.apple.com/forums/thread/111183
        let sourceForZoomDisable = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);"
        let scriptZoomDisable = WKUserScript(
            source: sourceForZoomDisable,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        eyezonWebView.configuration.userContentController.addUserScript(script)
        eyezonWebView.configuration.userContentController.addUserScript(scriptZoomDisable)
        
        /// register the bridge script that listens for the output
        eyezonWebView.configuration.userContentController.add(self, name: "logHandler")
    }
}

// MARK: - WKNavigationDelegate
extension EyezonWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        presenter.webViewLoaded()
        decisionHandler(.allow)
    }
}

// MARK: - WKScriptMessageHandler
extension EyezonWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let (eventName, eventDictionary) = presenter.mapConsoleEvent(message.body)
        guard !eventName.isEmpty, !eventDictionary.isEmpty else {
            return
        }
        broadcastReceiver?.onConsoleEvent(eventName: eventName, event: eventDictionary)
    }
}

// MARK: - EyezonWebViewProtocol
extension EyezonWebViewController: EyezonWebViewProtocol {
    func showError(with message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
}
