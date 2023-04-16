//
//  Model.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 22.05.22.
//

import Foundation

struct Session: Identifiable, Codable, Hashable {
    var id: Int16
    var location: String
    var name: String
    var date: Date
    var distance: Double
    var maxspeed: Double
    var duration: Double
    var locationId: Int16
    
    static func fromSesssionEntity(entity: SessionEntity) -> Session {
        return Session(
            id: 0,
            location: entity.location!,
            name: entity.name!,
            date: entity.date!,
            distance: entity.distance,
            maxspeed: entity.maxspeed,
            duration: entity.duration,
            locationId: 0
        )
    }
}
