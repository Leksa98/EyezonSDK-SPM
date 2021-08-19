//
//  SocketService.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 04.08.2021.
//

import Foundation
@_implementationOnly import SocketIO

private enum Constants {
    static let DIALOG_ID_FIELD_NAME = "dialogId"
    static let IO_OPTIONS_TRANSPORTS_WEBSOCKET = "websocket"
    static let IO_OPTIONS_TRANSPORTS_POLLING = "polling"
}

class BaseSocketServiceImpl: BaseSocketService {
    private var hasListeners = false
    private var options: SocketIOClientConfiguration {
        return SocketIOClientConfiguration(
            arrayLiteral: .compress, .forceWebsockets(true), .forcePolling(true), .version(.two), .log(true)
        )
    }
    private var manager: SocketManager!
    private var socketIo: SocketIOClient!
    weak var broadcastReceiver: EyezonBroadcastReceiver?
    
    func makeBaseUrl() -> URL {
        return URL(string: "")!
    }
    
    init() {
        initSocket()
    }
    
    private func initSocket() {
        guard manager == nil else {
            return
        }
        manager = SocketManager(
            socketURL: makeBaseUrl(),
            config: options
        )
        socketIo = manager.defaultSocket
    }
    
    func connect() {
        initSocket()
        guard !isConnected() else {
            return
        }
        socketIo.connect()
        addListeners()
    }
    
    func enterSocket() {
        let userId = Storage.shared.getClientId()
        if !userId.isEmpty {
            emitEvent(
                emitEvent: EnterSocketEvent(userId: userId)
            )
        }
    }
    
    func disconnect() {
        SocketServiceConstants.allCases.forEach { constant in
            socketIo?.off(constant.rawValue)
        }
        socketIo?.disconnect()
    }
    
    func isConnected() -> Bool {
        return socketIo.status == .connected
    }
    
    func emitEvent(emitEvent: OutcomingSocketEvent) {
        guard let enterSocketEvent = emitEvent as? EnterSocketEvent else {
            return
        }
        socketIo.emit(
            SocketServiceConstants.SOCKET_O_CONNECT_TO.rawValue,
            enterSocketEvent.userId
        )
    }
    
    private func addListeners() {
        guard !hasListeners else {
            return
        }
        hasListeners = true
        SocketServiceConstants.allCases.forEach { constant in
            socketIo.off(constant.rawValue)
        }
        socketIo.on(clientEvent: .connect) { [weak self] _, _ in
            self?.enterSocket()
        }
        socketIo.on(SocketServiceConstants.SOCKET_I_MESSAGE_RECEIVED.rawValue) { [weak self] data, _ in
            guard let dict = data[0] as? [String: Any],
                  let data = try? JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed),
                  let newMessage = try? JSONDecoder().decode(EyezonMessage.self, from: data) else {
                return
            }
            self?.sendNewMessageBroadcast(eyezonMessage: newMessage)
        }
        socketIo.on(SocketServiceConstants.SOCKET_I_DIALOG_DELETED.rawValue) { [weak self] data, _ in
            guard let dialogId = data[0] as? String else {
                return
            }
            self?.sendDialogDeletedBroadcast(dialogId: dialogId)
        }
        socketIo.on(SocketServiceConstants.SOCKET_I_DIALOG_RETURNED.rawValue) { [weak self] data, _ in
            guard let dict = data[0] as? [String: Any],
                  let dialogId = dict[Constants.DIALOG_ID_FIELD_NAME] as? String else {
                return
            }
            self?.sendDialogReturnedBroadcast(dialogId: dialogId)
        }
        socketIo.on(clientEvent: .disconnect) { [weak self] _, _ in
            self?.hasListeners = false
        }
    }
    
    private func sendNewMessageBroadcast(eyezonMessage: EyezonMessage) {
        broadcastReceiver?.onNewMessage(message: eyezonMessage)
    }
    
    private func sendDialogReturnedBroadcast(dialogId: String) {
        broadcastReceiver?.onDialogReturned(dialogId: dialogId)
    }
    
    private func sendDialogDeletedBroadcast(dialogId: String) {
        broadcastReceiver?.onDialogDeleted(dialogId: dialogId)
    }
}
