//
//  EyezonSDKData.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import Foundation

public class EyezonSDKData: Codable {
    let businessId: String
    let buttonId: String
    let widgetUrl: String
    let fcmToken: String
    
    var validUrl: String {
        "\(widgetUrl)&businessId=\(businessId)&buttonId=\(buttonId)"
    }
}
