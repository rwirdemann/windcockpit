//
//  LocationService.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 08.08.22.
//

import Foundation

protocol SuccessHandler {
    func success(locations: [Location])
}

protocol ErrorHandler {
    func error(message: String)
}

func loadLocations(successHandler: SuccessHandler, errorHandler: ErrorHandler) {
    guard let url = URL(string: "\(Constants.BASE_URL)/locations") else {
        errorHandler.error(message: "Invalid URL")
        return
    }
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let httpResponse = response as? HTTPURLResponse, error == nil else {
            errorHandler.error(message: "No valid response")
            return
        }
        
        if let error = error {
            errorHandler.error(message: error.localizedDescription)
            return
        }
        
        guard 200 ..< 300 ~= httpResponse.statusCode else {
            errorHandler.error(message: "Status code was \(httpResponse.statusCode), but expected 2xx")
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let locations = try! decoder.decode([Location].self, from: data!)
        DispatchQueue.main.async {
            successHandler.success(locations: locations)
        }
    }.resume()
}

func deleteLocation(location: Location, errorHandler: ErrorHandler) {
    guard let url = URL(string: "\(Constants.BASE_URL)/locations/\(location.id)") else {
        errorHandler.error(message: "Invalid URL")
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard let httpResponse = response as? HTTPURLResponse, error == nil else {
            errorHandler.error(message: "No valid response")
            return
        }
        
        if let error = error {
            errorHandler.error(message: error.localizedDescription)
            return
        }
        
        guard 200 ..< 300 ~= httpResponse.statusCode else {
            errorHandler.error(message: "Status code was \(httpResponse.statusCode), but expected 2xx")
            return
        }
    }.resume()
}
