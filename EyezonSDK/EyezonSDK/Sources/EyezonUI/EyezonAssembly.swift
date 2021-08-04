//
//  Assembly.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import Foundation
import UIKit
import WebKit

final class EyezonAssembly {
    
    static func viewController(
        with data: EyezonSDKData,
        and broadcastReceiver: EyezonBroadcastReceiver?
    ) -> UIViewController {
        var validUrl = data.validUrl
        if let fcmToken = Storage.shared.getFCMToken() {
            validUrl.append("&fcmToken=\(fcmToken)")
        }
        let viewController = EyezonWebViewController(widgetUrl: data.validUrl, broadcastReceiver: broadcastReceiver)
        let presenter = EyezonWebViewPresenterImpl(with: viewController)
        viewController.presenter = presenter
        return viewController
    }
}
