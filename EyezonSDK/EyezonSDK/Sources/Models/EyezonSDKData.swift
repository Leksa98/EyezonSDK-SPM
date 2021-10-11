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
    let widgetUrl: String?
    private var apnsToken: String? {
        Storage.shared.getAPNSToken()
    }
    private let application = "IOS_SDK"
    
    var validUrl: String {
        var validUrlString = "\(widgetUrl ?? UrlConstants.DEFAULT_WIDGET_URL)&businessId=\(businessId)&buttonId=\(buttonId)&application=\(application)"
        validUrlString.safeAppendToUrl(apnsToken, fieldName: "apnToken")
        return validUrlString
    }
    
    public init(
        businessId: String,
        buttonId: String,
        widgetUrl: String? = nil
    ) {
        self.businessId = businessId
        self.buttonId = buttonId
        self.widgetUrl = widgetUrl
    }
}
