//
//  SessionListViewModel.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 22.05.22.
//

import Foundation

final class SessionListViewModel: ObservableObject {
    @Published var sessions: [Session] = []
    @Published var locations: [Location] = []

    func getSessions() {
        self.sessions = MockData.sessions
    }
    
    func uploadSession(session: Session, callback: EventServiceCallback) {
        createSession(session: session, callback: callback)
    }

    func loadSessions() {
        guard let url = URL(string: "\(Constants.BASE_URL)/events") else {
            print("Invalid url...")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                   print("statusCode: \(httpResponse.statusCode)")
               }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let sessions = try! decoder.decode([Session].self, from: data!)
            DispatchQueue.main.async {
                self.sessions = sessions
            }
        }.resume()
    }
    
    func loadSpots() {
        guard let url = URL(string: "\(Constants.BASE_URL)/locations") else {
            print("Invalid url...")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                   print("statusCode: \(httpResponse.statusCode)")
               }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let locations = try! decoder.decode([Location].self, from: data!)
            DispatchQueue.main.async {
                self.locations = locations
            }
        }.resume()
    }
    
    func removeSession(index: Int) {
        let s = sessions[index]
        sessions.remove(at: index)
        guard let url = URL(string: "\(Constants.BASE_URL)/events/\(s.id)") else {
            print("Invalid url...")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
            }
        }.resume()
    }
    
    func replace(session: Session) {
        let index = indexOf(session: session)
        if index != -1 {
            sessions[index] = session
        }
    }
    
    func indexOf(session: Session) -> Int {
        for (index, element) in sessions.enumerated() {
            if element.id == session.id {
                return index
            }
        }
        return -1
    }
}

struct MockData {
    static var sessions = [Session(id:1, location:"Heiligenhafen", name: "Wingding", date: Date(), distance: 40000, maxspeed: 22, duration: 2),
                           Session(id:2, location:"Altenteil", name: "Wingding", date: Date(), distance: 40000, maxspeed: 22, duration: 2)]
}
