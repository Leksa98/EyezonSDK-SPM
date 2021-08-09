//
//  SocketServiceRu.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 04.08.2021.
//

import Foundation

final class SocketServiceRu: BaseSocketServiceImpl {
    static let instance = SocketServiceRu()
    
    private override init() {
        super.init()
    }
    override func makeBaseUrl() -> URL {
        return URL(string: UrlConstants.RELEASE_BASE_URL_RU)!
    }
}
