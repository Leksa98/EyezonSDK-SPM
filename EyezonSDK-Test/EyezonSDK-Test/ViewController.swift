//
//  ViewController.swift
//  EyezonSDK-Test
//
//  Created by Denis Borodavchenko on 04.08.2021.
//

import UIKit
import EyezonSDK

var apnToken = ""
var bundleID = ""

class ViewController: UIViewController {
    
    private enum Constants {
        static let EYEZON_WIDGET_URL = "https://storage.googleapis.com/eyezonfortest/test-widget/webview.html?eyezon&businessId=5d63fe246c2590002eecef83&language=ru&buttonId=5ec26f248107de3797f0807c&target=SKU-1&title=Samsung%20Television&apnToken=\(apnToken)&application=\(bundleID)&eyezonRegion=sandbox"
        
        static let EYEZON_BUSINESS_ID = "5d63fe246c2590002eecef83"
        static let EYEZON_BUTTON_ID = "5ec26f248107de3797f0807c"
    }
    
    private var predefinedData: EyezonSDKData {
        EyezonSDKData(
            businessId: Constants.EYEZON_BUSINESS_ID,
            buttonId: Constants.EYEZON_BUTTON_ID,
            widgetUrl: Constants.EYEZON_WIDGET_URL
        )
    }
    
    private var servers: [ServerArea] {
        [.russia, .europe, .usa, .sandbox]
    }
    private let selectedServer: ServerArea = .sandbox
    
    private lazy var eyezonButton: UIButton = {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 40)))
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(openEyezon), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("SDK TEST", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(eyezonButton)
        let constraints = [
            eyezonButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            eyezonButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            eyezonButton.widthAnchor.constraint(equalToConstant: 100),
            eyezonButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc
    private func openEyezon() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        apnToken = delegate?.pushToken ?? "Device token is empty"
        
        bundleID = Bundle.main.bundleIdentifier ?? "BundleID is empty"
        
        Eyezon.instance.initSdk(area: selectedServer) { [weak self, predefinedData] in
            let eyezonWebViewController = Eyezon.instance.openButton(data: predefinedData, broadcastReceiver: self)
            self?.navigationController?.pushViewController(eyezonWebViewController, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension ViewController: EyezonBroadcastReceiver {
    func onConsoleEvent(eventName: String, event: [String: Any]) {
        print(#function, " \(eventName)")
    }
}

