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
    private var eyezonWebView: WKWebView!
    private let widgetUrl: String
    private weak var broadcastReceiver: EyezonBroadcastReceiver?
    
    // MARK: - Public properties
    var presenter: EyezonWebViewPresenter!
    
    // MARK: - Lifecycle
    
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
        makeWebView()
        view.addSubview(eyezonWebView)
        guard let url = URL(string: widgetUrl) else {
            return
        }
        let urlRequest = URLRequest(url: url)
        eyezonWebView.load(urlRequest)
        constraintView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Eyezon"
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        eyezonWebView.evaluateJavaScript(EyezonJSConstants.leaveDialog)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.presenter.webViewClose()
            self.eyezonWebView?.configuration.userContentController.removeScriptMessageHandler(forName: "logHandler")
        }
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
    
    private func makeWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.applicationNameForUserAgent = "Safari" //Fix for old version of WebSDK
        injectingScripts(in: configuration)
        eyezonWebView = WKWebView(frame: view.bounds, configuration: configuration)
        eyezonWebView.navigationDelegate = self
        eyezonWebView.uiDelegate = self
        eyezonWebView.translatesAutoresizingMaskIntoConstraints = false
        WKWebsiteDataStore.default().removeData(
            ofTypes: .init(arrayLiteral: WKWebsiteDataTypeDiskCache),
            modifiedSince: Date(timeIntervalSince1970: .zero),
            completionHandler: { }
        )
    }
    
    private func injectingScripts(in configuration: WKWebViewConfiguration) {
        /// For listening console events
        let script = WKUserScript(
            source: EyezonJSConstants.listeningConsoleEvents,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        
        /// For disabling zoom-in
        /// https://developer.apple.com/forums/thread/111183
        let scriptZoomDisable = WKUserScript(
            source: EyezonJSConstants.sourceForZoomDisable,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        configuration.userContentController.addUserScript(script)
        configuration.userContentController.addUserScript(scriptZoomDisable)
        /// register the bridge script that listens for the output
        configuration.userContentController.add(self, name: "logHandler")
    }
}

// MARK: - WKUIDelegate
extension EyezonWebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        return nil
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
        let alertVC = UIAlertController(title: "unknownError".localizedFromJSON, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok".localizedFromJSON, style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.navigationController?.popViewController(animated: true)
        })
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
}
