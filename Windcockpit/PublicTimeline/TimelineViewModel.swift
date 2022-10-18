//
//  SessionListViewModel.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 22.05.22.
//

import Foundation
import CoreData
import SwiftUI

final class TimelineViewModel: ObservableObject {
    
    @Published var sessions: [Session] = []
    @Published var locations: [Location] = []
    
    func getSessions() {
        self.sessions = MockData.sessions
    }
    
    func uploadSession(session: Session, callback: SessionServiceCallback) {
        createSession(session: session, callback: callback, managedObjectID: nil)
    }
    
    fileprivate func addSessionsToCodeData(_ viewContext: NSManagedObjectContext) {
        for session in self.sessions {
            let exists = self.itemExists(viewContext: viewContext, item: session)
            if exists == false {
                let newItem = SessionEntity(context: viewContext)
                newItem.date = session.date
                newItem.location = session.location
                newItem.name = session.name
                newItem.cid = Int32(session.id)
                newItem.distance = session.distance
                newItem.maxspeed = session.maxspeed
                newItem.duration = session.duration
                newItem.published = true
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func loadSessions(viewContext: NSManagedObjectContext? = nil) {
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
            self.sessions = try! decoder.decode([Session].self, from: data!)
        }.resume()
    }
    
    private func itemExists(viewContext: NSManagedObjectContext, item: Session) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SessionEntity")
        fetchRequest.predicate = NSPredicate(format: "cid == %d", item.id)
        return ((try? viewContext.count(for: fetchRequest)) ?? 0) > 0
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
