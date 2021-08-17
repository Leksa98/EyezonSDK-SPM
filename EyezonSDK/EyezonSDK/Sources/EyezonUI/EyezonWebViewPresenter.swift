//
//  EyezonWebViewPresenter.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 05.08.2021.
//

import Foundation
@_implementationOnly import  SwiftyJSON

/// View protocol
protocol EyezonWebViewProtocol: AnyObject {
    /// Calling if timer was ended and needed events wasn't received
    func showError(with message: String)
}

/// Presenter protocol
protocol EyezonWebViewPresenter: AnyObject {
    init(with view: EyezonWebViewProtocol)
    
    /// Firing timer with 5 sec interval for
    func webViewLoaded()
    
    /// Map console events
    func mapConsoleEvent(_ value: Any) -> (eventName: String, eventData: [String: Any])
    
    /// Connect to sockets because we leaving webview
    func webViewClose()
}

final class EyezonWebViewPresenterImpl: EyezonWebViewPresenter {
    
    /// Nested type
    private enum NeededEvents: String {
        case buttonClicked = "BUTTON_CLICKED"
        case chatJoined = "CHAT_JOINED"
    }
    
    // MARK: - Private properties
    private let emptyTuple = ("", [String: Any]())
    private var timer: Timer?
    private var buttonClickedReceived = false
    private var chatJoinedReceived = false
    private let socketService = SocketServiceProvider().getInstance()
    
    // MARK: - Public properties
    weak var view: EyezonWebViewProtocol?

    // MARK: - Lifecycle
    init(with view: EyezonWebViewProtocol) {
        self.view = view
    }
    
    // MARK: - Public methods
    func webViewLoaded() {
        socketService.disconnect()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { [weak self] timer in
            self?.view?.showError(with: "")
            timer.invalidate()
        })
    }
    
    func mapConsoleEvent(_ value: Any) -> (eventName: String, eventData: [String : Any]) {
        guard let bodyString = value as? String else {
            return emptyTuple
        }
        let json = JSON(parseJSON: bodyString)
        guard let eventName = json.array?[safe: 0]?.string,
              let eventDictionary = json.array?[safe: 1]?.dictionaryObject else {
            return emptyTuple
        }
        if eventName == NeededEvents.buttonClicked.rawValue {
            buttonClickedReceived = true
        } else if eventName == NeededEvents.chatJoined.rawValue {
            chatJoinedReceived = true
        }
        if let data = try? json.array?[safe: 1]?.rawData(),
            let knownClient = try? JSONDecoder().decode(KnownClient.self, from: data) {
            Storage.shared.setClientId(knownClient.eyezonClientId)
        }
        if buttonClickedReceived && chatJoinedReceived && timer != nil {
            /// Needed events received then we need stop timer
            eyezonDidLoad()
        }
        return (eventName, eventDictionary)
    }
    
    func webViewClose() {
        socketService.connect()
    }
    
    // MARK: - Private methods
    private func eyezonDidLoad() {
        timer?.invalidate()
        timer = nil
    }
}
