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
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        let bundle = Bundle(for: type(of: self))
        button.setImage(UIImage(named: "Close", in: bundle, with: nil), for: .normal)
        button.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lightGray
        button.tintColor = .black
        button.layer.cornerRadius = 12.0
        return button
    }()
    private let widgetUrl: String
    private var observable: NSKeyValueObservation?
    private weak var broadcastReceiver: EyezonBroadcastReceiver?
    
    // MARK: - Public properties
    var presenter: EyezonWebViewPresenter!
    override var modalPresentationStyle: UIModalPresentationStyle {
        get {
            return .fullScreen
        }
        set { }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
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
        view.addSubview(eyezonWebView)
        view.addSubview(closeButton)
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
        eyezonWebView.evaluateJavaScript(EyezonJSConstants.leaveDialog)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.webViewClose()
    }
    
    // MARK: - Private methods
    private func constraintView() {
        let constraints = [
            eyezonWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            eyezonWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            eyezonWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            eyezonWebView.topAnchor.constraint(equalTo: view.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 24.0),
            closeButton.heightAnchor.constraint(equalToConstant: 24.0)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func injectingScripts() {
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
        eyezonWebView.configuration.userContentController.addUserScript(script)
        eyezonWebView.configuration.userContentController.addUserScript(scriptZoomDisable)
        
        /// register the bridge script that listens for the output
        eyezonWebView.configuration.userContentController.add(self, name: "logHandler")
    }
    
    @objc
    private func close() {
        dismiss(animated: true, completion: nil)
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
            self?.navigationController?.popViewController(animated: true)
        })
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
}
