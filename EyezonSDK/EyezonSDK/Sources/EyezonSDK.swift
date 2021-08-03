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

public class EyezonSDK {
    static let instance = EyezonSDK()
    private var socketService: BaseSocketService?
    
    private init() { }
    
    public func initSdk(
        area: ServerArea
    ) {
        socketService = SocketServiceProvider().getInstance()
        Storage.shared.setCurrentServer(area)
    }
    
    
    /// Method for providing FCM token to Eyezon
    public func updateFCM(_ token: String) {
        Storage.shared.setFCMToken(token)
    }
    
    /// Method for opening EyezonWebView
    /// return UIViewController in which webView embedded
    public func openButton(data: EyezonSDKData, broadcastReceiver: EyezonBroadcastReceiver) -> UIViewController {
        socketService?.broadcastReceiver = broadcastReceiver
        return EyezonAssembly.viewController(with: data, and: broadcastReceiver)
    }
}
