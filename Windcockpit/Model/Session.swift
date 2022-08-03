//
//  Model.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 22.05.22.
//

import Foundation

struct Session: Identifiable, Codable, Hashable {
    var id: Int
    var location: String
    var name: String
    var date: Date
    var distance: Double
    var maxspeed: Double
    var duration: Double
}
