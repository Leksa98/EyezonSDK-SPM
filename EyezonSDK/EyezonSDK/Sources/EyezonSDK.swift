//
//  EyezonSDK.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import Foundation
import UIKit

public enum ServerArea: String {
    case sandbox = "sandbox"
    case europe = "eu"
    case russia = "ru"
    case usa = "us"
}

public class EyezonSDK: NSObject {
    public static let instance = EyezonSDK()
    private var socketService: BaseSocketService?
    weak var broadcastReceiver: EyezonBroadcastReceiver?
    
    private override init() {
        super.init()
    }
    
    public func initSdk(
        area: ServerArea,
        completion: @escaping () -> Void
    ) {
        _ = LocalizationService.shared
        socketService = SocketServiceProvider().getInstance()
        Storage.shared.setCurrentServer(area)
        completion()
    }
    
    public func initMessaging(apnsData: Data) {
        let tokenString = apnsData.reduce("") { $0 + String(format: "%02.2hhx", $1) }
        Storage.shared.setAPNSToken(tokenString)
    }
    
    /// Method for opening EyezonWebView
    /// return UIViewController in which webView embedded
    public func openButton(data: EyezonSDKData, broadcastReceiver: EyezonBroadcastReceiver?) -> UIViewController {
        self.broadcastReceiver = broadcastReceiver
        socketService?.broadcastReceiver = broadcastReceiver
        return EyezonAssembly.viewController(with: data, and: broadcastReceiver)
    }
}
