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
        with data: EyezonSDKData
    ) -> UIViewController {
        let viewController = EyezonWebViewController(widgetUrl: data.validUrl)
        let presenter = EyezonWebViewPresenterImpl(with: viewController)
        viewController.presenter = presenter
        return viewController
    }
}
