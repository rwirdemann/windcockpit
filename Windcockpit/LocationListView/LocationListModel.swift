//
//  SpotListModel.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 08.08.22.
//

import Foundation
import CoreData

protocol LocationServiceCallback {
    func success(locations: [Location])
    func error(message: String)
}

final class LocationListModel: ObservableObject {
    @Published var locations: [Location] = []
    
    func success(locations: [Location]) {
        self.locations = locations
    }
    
    func loadLocations(cb: LocationServiceCallback, viewContext: NSManagedObjectContext? = nil) {
        guard let url = URL(string: "\(Constants.BASE_URL)/locations") else {
            cb.error(message: "Invalid URL")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
                cb.error(message: "No valid response")
                return
            }
            
            if let error = error {
                cb.error(message: error.localizedDescription)
                return
            }
            
            guard 200 ..< 300 ~= httpResponse.statusCode else {
                cb.error(message: "Status code was \(httpResponse.statusCode), but expected 2xx")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let locations = try! decoder.decode([Location].self, from: data!)
            DispatchQueue.main.async {
                self.locations = locations
                if let viewContext = viewContext {
                    for l in self.locations {
                        let exists = self.itemExists(viewContext: viewContext, item: l)
                        if exists == false {
                            let newItem = LocationEntity(context: viewContext)
                            newItem.name = l.name
                            newItem.cid = Int32(l.id)
                        }
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                }
            }
        }.resume()
    }
    
    private func itemExists(viewContext: NSManagedObjectContext, item: Location) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationEntity")
        fetchRequest.predicate = NSPredicate(format: "cid == %d", item.id)
        return ((try? viewContext.count(for: fetchRequest)) ?? 0) > 0
    }
    
    func deleteLocation(index: Int, cb: LocationServiceCallback) {
        let l = locations[index]

        guard let url = URL(string: "\(Constants.BASE_URL)/locations/\(l.id)") else {
            cb.error(message: "Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
                cb.error(message: "No valid response")
                return
            }
            
            if let error = error {
                cb.error(message: error.localizedDescription)
                return
            }
            
            guard 200 ..< 300 ~= httpResponse.statusCode else {
                cb.error(message: "Status code was \(httpResponse.statusCode), but expected 2xx")
                return
            }
            
            self.locations.remove(at: index)
        }.resume()
    }
}

