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