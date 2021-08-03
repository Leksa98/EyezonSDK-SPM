//
//  SocketServiceProvider.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 04.08.2021.
//

import Foundation

final class SocketServiceProvider {
    private let area = Storage.shared.getCurrentServer()
    
    func getInstance() -> BaseSocketService {
        switch area {
        case .europe:
            return SocketServiceEu.instance
        case .russia:
            return SocketServiceRu.instance
        case .usa:
            return SocketServiceUs.instance
        case .sandbox:
            return SocketServiceSandbox.instance
        }
    }
    
}
