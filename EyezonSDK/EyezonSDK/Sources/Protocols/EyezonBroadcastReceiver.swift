//
//  EyezonBroadcastReceiver.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import Foundation

/// Protocol for interacting with eyezon events
public protocol EyezonBroadcastReceiver: AnyObject {
    
    /// Event for indicating that new message was received
    func onNewMessage(message: EyezonMessage)
    
    /// Event for indicating that dialog was created
    func onDialogCreated(dialogId: String)
    
    /// Event for indicating that dialog was deleted
    func onDialogDeleted(dialogId: String)
    
    /// Event for indicating that dialog was returned
    func onDialogReturned(dialogId: String)
    
    /// Event for indicating other console events
    func onConsoleEvent(eventName: String, event: [String: Any])
}
