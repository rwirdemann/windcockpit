//
//  SpotListModel.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 08.08.22.
//

import Foundation

final class LocationListModel: ObservableObject, SuccessHandler {
    @Published var locations: [Location] = []
    
    func success(locations: [Location]) {
        self.locations = locations
    }
    
    func loadLocations(errorHandler: ErrorHandler) {
        Windcockpit.loadLocations(successHandler: self, errorHandler: errorHandler)
    }
    
    func deleteLocation(index: Int, errorHandler: ErrorHandler) {
        let l = locations[index]
        locations.remove(at: index)
        Windcockpit.deleteLocation(location: l, errorHandler: errorHandler)
    }
}
