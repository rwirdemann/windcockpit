//
//  Formatter.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 02.08.22.
//

import Foundation

struct Formatters {
    static let number: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}

func short(name: String) -> String {
    switch name {
    case "Wingfoiling", "Wingding": return "WF"
    case "Windsurfing": return "WS"
    case "Kitesurfing": return "KS"
    default: return name
    }
}
