//
//  date.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 30.05.22.
//

import Foundation

func toString(from: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "de")
    formatter.dateFormat = "EEEE, d. MMMM y, HH:mm"

    
    formatter.locale = Locale(identifier: "de")
    return formatter.string(from: from)
}
