import Foundation
import CoreData

func createSession(session: Session, success: @escaping (_ : Int16) -> Void, error: @escaping (_ : String) -> Void) {
    guard let url = URL(string: "\(Constants.BASE_URL)/events") else {
        error("Invalid URL")
        return
    }
    var request = URLRequest(url: url)
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let json = try! encoder.encode(session)
    request.httpMethod = "POST"
    request.httpBody = json
    let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
        guard let httpResponse = response as? HTTPURLResponse, err == nil else {
            error("No valid response")
            return
        }
        
        if let err = err {
            error(err.localizedDescription)
            return
        }
        
        guard 200 ..< 300 ~= httpResponse.statusCode else {
            error("Status code was \(httpResponse.statusCode), but expected 2xx")
            return
        }
        
        guard let location = httpResponse.value(forHTTPHeaderField: "Location") else {
            error("No Location header found")
            return
        }

        guard let id = extractIdFromLocationHeader(url: location) else {
            error("Location header contains no valid id")
            return
        }

        DispatchQueue.main.async {
            success(id)
        }
    }
    task.resume()
}

func updateSession(session: Session, error: @escaping (_ : String) -> Void) {
    guard let url = URL(string: "\(Constants.BASE_URL)/events/\(session.id)") else {
        error("Invalid URL")
        return
    }
    var request = URLRequest(url: url)
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let json = try! encoder.encode(session)
    request.httpMethod = "PUT"
    request.httpBody = json
    let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
        guard let httpResponse = response as? HTTPURLResponse, err == nil else {
            error("No valid response")
            return
        }
        
        if let err = err {
            error(err.localizedDescription)
            return
        }
        
        guard 200 ..< 300 ~= httpResponse.statusCode else {
            error("Status code was \(httpResponse.statusCode), but expected 2xx")
            return
        }
    }
    task.resume()
}

func createLocation(location: Location, success: @escaping (_ : Int16) -> Void, error: @escaping (_ : String) -> Void) {
    guard let url = URL(string: "\(Constants.BASE_URL)/locations") else {
        error("Invalid URL")
        return
    }
    var request = URLRequest(url: url)
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let json = try! encoder.encode(location)
    request.httpMethod = "POST"
    request.httpBody = json
    let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
        guard let httpResponse = response as? HTTPURLResponse, err == nil else {
            error("No valid response")
            return
        }
        
        if let err = err {
            error(err.localizedDescription)
            return
        }
        
        guard 200 ..< 300 ~= httpResponse.statusCode else {
            error("Status code was \(httpResponse.statusCode), but expected 2xx")
            return
        }
        
        guard let location = httpResponse.value(forHTTPHeaderField: "Location") else {
            error("No Location header found")
            return
        }

        guard let id = extractIdFromLocationHeader(url: location) else {
            error("Location header contains no valid id")
            return
        }
        
        success(id)
    }
    task.resume()
}
