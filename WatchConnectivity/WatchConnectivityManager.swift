//
//  WatchConnectivityManager.swift
//  WeatherApp
//
//  Created by Bahalek on 2022-01-04.
//

import Foundation
import WatchConnectivity

final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    @Published var newSessions: [Session]? = nil

    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func isConnected() -> Bool {
        return WCSession.default.activationState == .activated
    }
    
    enum ConnectivityError: Error {
      case companionAppNotInstalled
    }
    
    func send(_ sessions: [Session], replyHandler: @escaping ((Data) -> Void), errorHandler: @escaping ((Error) -> Void)) {
        guard WCSession.default.activationState == .activated else {
          return
        }
        #if os(iOS)
        guard WCSession.default.isWatchAppInstalled else {
            return
        }
        #else
        guard WCSession.default.isCompanionAppInstalled else {
            errorHandler(ConnectivityError.companionAppNotInstalled)
            return
        }
        #endif
 
        let encoder = JSONEncoder()
        let data = try! encoder.encode(sessions)
        WCSession.default.sendMessageData(data, replyHandler: replyHandler, errorHandler: errorHandler)
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        let decoder = JSONDecoder()
        let sessions = try! decoder.decode([Session].self, from: messageData)
        DispatchQueue.main.async { [weak self] in
            self?.newSessions = sessions
            replyHandler(Data("ok".utf8))
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
