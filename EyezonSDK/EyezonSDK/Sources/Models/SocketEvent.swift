//
//  SocketEvent.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 03.08.2021.
//

import Foundation

protocol IncomingSocketEvent: Codable { }
protocol OutcomingSocketEvent: Codable { }

/// Incoming events
struct DeletedDialogEvent: IncomingSocketEvent {
    let dialogId: String
}

struct DialogReturnedEvent: IncomingSocketEvent {
    let dialogId: String
}

struct NewMessageEvent: IncomingSocketEvent {
    let eyezonMessage: EyezonMessage
}

/// Outcoming events
struct EnterSocketEvent: OutcomingSocketEvent {
    let userId: String
}

/// Analytics event
struct AnalyticsEvent {
    static let EVENT_INIT_SDK = "init_sdk"
}

///Webview event
struct KnownClient: Codable {
    let eyezonClientId: String
}
