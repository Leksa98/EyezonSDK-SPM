//
//  EyezonSDK.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import Foundation
import UIKit
import FirebaseAnalytics
import FirebaseCore
import FirebaseMessaging

public enum ServerArea: String {
    case sandbox = "sandbox"
    case europe = "eu"
    case russia = "ru"
    case usa = "us"
}

public class EyezonSDK {
    public static let instance = EyezonSDK()
    private var socketService: BaseSocketService?
    
    private init() {
        if let filePath = Bundle(for: type(of: self)).path(forResource: "GoogleService-Info", ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: filePath) {
            FirebaseApp.configure(options: options)
        }
    }
    
    public func initSdk(
        area: ServerArea
    ) {
        socketService = SocketServiceProvider().getInstance()
        Storage.shared.setCurrentServer(area)
        socketService?.connect()
        Analytics.logEvent(AnalyticEvents.EVENT_INIT_SDK, parameters: nil)
    }
    
    
    /// Method for providing FCM token to Eyezon
    public func updateFCM(_ token: String) {
        Storage.shared.setFCMToken(token)
    }
    
    /// Method for opening EyezonWebView
    /// return UIViewController in which webView embedded
    public func openButton(data: EyezonSDKData, broadcastReceiver: EyezonBroadcastReceiver?) -> UIViewController {
        socketService?.broadcastReceiver = broadcastReceiver
        return EyezonAssembly.viewController(with: data, and: broadcastReceiver)
    }
}
