//
//  EyezonMessaging.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 06.08.2021.
//

import Foundation
import UIKit
import FirebaseMessaging

final public class EyezonMessaging: Messaging {
    
    public override func appDidReceiveMessage(_ message: [AnyHashable : Any]) -> MessagingMessageInfo {
        EyezonSDK.instance.broadcastReceiver?.onPushReceived(title: "", body: "")
        return super.appDidReceiveMessage(message)
    }
}
