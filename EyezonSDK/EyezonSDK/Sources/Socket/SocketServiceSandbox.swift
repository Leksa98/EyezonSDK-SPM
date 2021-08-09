//
//  SocketServiceSandbox.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 04.08.2021.
//

import Foundation

final class SocketServiceSandbox: BaseSocketServiceImpl {
    static let instance = SocketServiceSandbox()
    
    private override init() {
        super.init()
    }
    
    override func makeBaseUrl() -> URL {
        return URL(string: UrlConstants.DEBUG_BASE_URL)!
    }
}
