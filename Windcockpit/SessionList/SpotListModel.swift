//
//  SpotListModel.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 01.09.22.
//

import Foundation

final class SpotListModel: ObservableObject {
    
    @Published var locations: [Location] = []
    
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
}
