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

public class EyezonSDK: NSObject {
    public static let instance = EyezonSDK()
    private var socketService: BaseSocketService?
    private var messaging: EyezonMessaging?
    weak var broadcastReceiver: EyezonBroadcastReceiver?
    
    private override init() {
        super.init()
    }
    
    public func initEyezonFirebase() {
        if let filePath = Bundle(for: type(of: self)).path(forResource: "GoogleService-Info", ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: filePath) {
            FirebaseApp.configure(options: options)
            EyezonMessaging.messaging().delegate = self
        }
    }
    
    public func initSdk(
        area: ServerArea,
        completion: @escaping () -> Void
    ) {
        _ = LocalizationService.shared
        socketService = SocketServiceProvider().getInstance()
        Storage.shared.setCurrentServer(area)
        #if !DEBUG
        Analytics.logEvent(AnalyticEvents.EVENT_INIT_SDK, parameters: nil)
        #endif
        completion()
    }
    
    public func initMessaging(apnsData: Data) {
        EyezonMessaging.messaging().apnsToken = apnsData
        EyezonMessaging.messaging().retrieveFCMToken(forSenderID: "145317142740") { token, _ in
            guard let token = token else {
                return
            }
            print("FCM TOKEN \(token)")
            Storage.shared.setFCMToken(token)
        }
    }
    
    /// Method for providing FCM token to Eyezon
    public func updateFCM(_ token: String) {
        Storage.shared.setFCMToken(token)
    }
    
    /// Method for opening EyezonWebView
    /// return UIViewController in which webView embedded
    public func openButton(data: EyezonSDKData, broadcastReceiver: EyezonBroadcastReceiver?) -> UIViewController {
        self.broadcastReceiver = broadcastReceiver
        socketService?.broadcastReceiver = broadcastReceiver
        return EyezonAssembly.viewController(with: data, and: broadcastReceiver)
    }
}

extension EyezonSDK: MessagingDelegate {
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Storage.shared.setFCMToken(fcmToken ?? .empty)
    }
}
