//
//  EyezonSDKData.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import Foundation

public class EyezonSDKData {
    let businessId: String
    let buttonId: String
    let widgetUrl: String
    var fcmToken: String = ""
    private let application = "IOSSDK"
    
    var validUrl: String {
        "\(widgetUrl)&businessId=\(businessId)&buttonId=\(buttonId)&application=\(application)"
    }
    
    public init(
        businessId: String,
        buttonId: String,
        widgetUrl: String
    ) {
        self.businessId = businessId
        self.buttonId = buttonId
        self.widgetUrl = widgetUrl
    }
}
