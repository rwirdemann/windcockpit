//
//  SpotListModel.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 08.08.22.
//

import Foundation

final class LocationListModel: ObservableObject, LocationServiceCallback {
    @Published var locations: [Location] = []

    func success(locations: [Location]) {
        self.locations = locations
    }
    
    func error(message: String) {
        print(message)
    }
        
    func loadLocations() {
        Windcockpit.loadLocations(callback: self)
    }
}
