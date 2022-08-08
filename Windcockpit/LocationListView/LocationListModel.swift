//
//  SpotListModel.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 08.08.22.
//

import Foundation

protocol LocationServiceCallback {
    func success(locations: [Location])
    func error(message: String)
}

final class LocationListModel: ObservableObject {
    @Published var locations: [Location] = []
    
    func success(locations: [Location]) {
        self.locations = locations
    }
    
    func loadLocations(cb: LocationServiceCallback) {
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
            }
        }.resume()
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

