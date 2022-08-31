//
//  WatchConnectivityManager.swift
//  WeatherApp
//
//  Created by Bahalek on 2022-01-04.
//

import Foundation
import WatchConnectivity

struct NotificationMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    
    static func ==(lhs: NotificationMessage, rhs: NotificationMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    @Published var notificationMessage: NotificationMessage? = nil
    @Published var newSession: Session? = nil

    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    private let kMessageKey = "message"

    func isConnected() -> Bool {
        return WCSession.default.activationState == .activated
    }
    
    func send(_ session: Session) {
        guard WCSession.default.activationState == .activated else {
          return
        }
        #if os(iOS)
        guard WCSession.default.isWatchAppInstalled else {
            return
        }
        #else
        guard WCSession.default.isCompanionAppInstalled else {
            return
        }
        #endif
 
        let encoder = JSONEncoder()
        let data = try! encoder.encode(session)
        WCSession.default.sendMessageData(data, replyHandler: nil) { error in
            print("Cannot send data: \(String(describing: error))")
        }
    }

    func send(_ message: String) {
        guard WCSession.default.activationState == .activated else {
          return
        }
        #if os(iOS)
        guard WCSession.default.isWatchAppInstalled else {
            return
        }
        #else
        guard WCSession.default.isCompanionAppInstalled else {
            return
        }
        #endif
        
        WCSession.default.sendMessage([kMessageKey : message], replyHandler: nil) { error in
            print("Cannot send message: \(String(describing: error))")
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let notificationText = message[kMessageKey] as? String {
            DispatchQueue.main.async { [weak self] in
                self?.notificationMessage = NotificationMessage(text: notificationText)
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        let decoder = JSONDecoder()
        let session = try! decoder.decode(Session.self, from: messageData)
        DispatchQueue.main.async { [weak self] in
            self?.newSession = session
        }
    }
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {}
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
