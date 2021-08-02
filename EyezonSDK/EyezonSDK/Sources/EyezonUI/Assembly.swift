//
//  Assembly.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import Foundation
import UIKit
import WebKit

class EyezonAssembly {
    static func viewController(
        with data: EyezonSDKData,
        and broadcastReceiver: EyezonBroadcastReceiver?
    ) -> UIViewController {
        let viewController = EyezonWebViewController(widgetUrl: data.validUrl)
        return viewController
    }
}
