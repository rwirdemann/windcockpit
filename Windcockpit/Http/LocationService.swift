//
//  LocationService.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 28.06.22.
//

import Foundation
import CoreData

protocol LocationServiceCallback {
    func locationSuccess(locationId: Int16, managedObjectID: NSManagedObjectID?, session: SessionEntity)
    func locationError(message: String)
}

func createLocation(location: Location, callback: LocationServiceCallback, managedObjectID: NSManagedObjectID?, session: SessionEntity) {
    guard let url = URL(string: "\(Constants.BASE_URL)/locations") else {
        callback.locationError(message: "Invalid URL")
        return
    }
    var request = URLRequest(url: url)
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let json = try! encoder.encode(location)
    request.httpMethod = "POST"
    request.httpBody = json
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard let httpResponse = response as? HTTPURLResponse, error == nil else {
            callback.locationError(message: "No valid response")
            return
        }
        
        if let error = error {
            callback.locationError(message: error.localizedDescription)
            return
        }
        
        guard 200 ..< 300 ~= httpResponse.statusCode else {
            callback.locationError(message: "Status code was \(httpResponse.statusCode), but expected 2xx")
            return
        }
        
        guard let location = httpResponse.value(forHTTPHeaderField: "Location") else {
            callback.locationError(message: "No Location header found")
            return
        }

        guard let id = extractIdFromLocationHeader(url: location) else {
            callback.locationError(message: "Location header contains no valid id")
            return
        }

        callback.locationSuccess(locationId: id, managedObjectID: managedObjectID, session: session)
    }
    task.resume()
}
