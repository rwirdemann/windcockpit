import Foundation
import CoreData

protocol ManagedObjectLocationServiceCallback {
    func success(id: Int, managedObjectID: NSManagedObjectID?)
    func error(message: String)
}

func create(location: Location, callback: ManagedObjectLocationServiceCallback, managedObjectID: NSManagedObjectID?) {
    guard let url = URL(string: "\(Constants.BASE_URL)/locations") else {
        callback.error(message: "Invalid URL")
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
        
        guard let location = httpResponse.value(forHTTPHeaderField: "Location") else {
            callback.error(message: "No Location header found")
            return
        }

        guard let id = extractIdFromLocationHeader(url: location) else {
            callback.error(message: "Location header contains no valid id")
            return
        }

        callback.success(id: id, managedObjectID: managedObjectID)
    }
    task.resume()
}
