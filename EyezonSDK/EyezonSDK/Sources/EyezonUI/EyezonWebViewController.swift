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
    }
}

extension EyezonWebViewController: WKUIDelegate {
    func webViewDidClose(_ webView: WKWebView) {
        
    }
}
