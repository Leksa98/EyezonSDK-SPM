//
//  BaseSocketService.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 04.08.2021.
//

import Foundation

enum SocketServiceConstants: String {
    case SOCKET_O_CONNECT_TO = "enterSocket"
    case SOCKET_I_DIALOG_RETURNED = "requestReturnedUpdated"
    case SOCKET_I_DIALOG_DELETED = "dialogDeleted"
    case SOCKET_I_MESSAGE_RECEIVED = "received"
    
    static var allCases: [SocketServiceConstants] {
        return [.SOCKET_O_CONNECT_TO, .SOCKET_I_MESSAGE_RECEIVED, .SOCKET_I_DIALOG_DELETED, .SOCKET_I_DIALOG_RETURNED]
    }
}

protocol BaseSocketService {
    var broadcastReceiver: EyezonBroadcastReceiver? { get set }
    func connect()
    func enterSocket()
    func disconnect()
    func isConnected() -> Bool
    func emitEvent(emitEvent: OutcomingSocketEvent)
}
