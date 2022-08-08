//
//  LocationService.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 08.08.22.
//

import Foundation

protocol LocationServiceCallback {
    func success(locations: [Location])
    func error(message: String)
}

func loadLocations(callback: LocationServiceCallback) {
    guard let url = URL(string: "\(Constants.BASE_URL)/locations") else {
        callback.error(message: "Invalid URL")
        return
    }
    URLSession.shared.dataTask(with: url) { data, response, error in
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

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let locations = try! decoder.decode([Location].self, from: data!)
        DispatchQueue.main.async {
            callback.success(locations: locations)
        }
    }.resume()
}


