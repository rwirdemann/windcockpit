//
//  EventService.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 20.07.22.
//

import Foundation

protocol EventServiceCallback {
    func success(event: Session)
    func error(message: String)
}

func createSession(session: Session, callback: EventServiceCallback) {
    guard let url = URL(string: "\(Constants.BASE_URL)/events") else {
        callback.error(message: "Invalid URL")
        return
    }
    var request = URLRequest(url: url)
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let json = try! encoder.encode(session)
    request.httpMethod = "POST"
    request.httpBody = json
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard let httpResponse = response as? HTTPURLResponse, error == nil else {
            callback.error(message: "No valid response")
            return
        }

        if let error = error {
            callback.error(message: error.localizedDescription)
            return
        }
        
        guard 200 ..< 300 ~= httpResponse.statusCode else {
            callback.error(message: "Status code was \(httpResponse.statusCode), but expected 2xx")
            return
       }

        callback.success(event: session)
    }
    task.resume()
}

func updateSession(session: Session, callback: EventServiceCallback) {
    guard let url = URL(string: "\(Constants.BASE_URL)/events/\(session.id)") else {
        callback.error(message: "Invalid URL")
        return
    }
    var request = URLRequest(url: url)
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let json = try! encoder.encode(session)
    request.httpMethod = "PUT"
    request.httpBody = json
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard let httpResponse = response as? HTTPURLResponse, error == nil else {
            callback.error(message: "No valid response")
            return
        }

        if let error = error {
            callback.error(message: error.localizedDescription)
            return
        }
        
        guard 200 ..< 300 ~= httpResponse.statusCode else {
            callback.error(message: "Status code was \(httpResponse.statusCode), but expected 2xx")
            return
       }

        callback.success(event: session)
    }
    task.resume()
}
