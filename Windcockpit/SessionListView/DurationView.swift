//
//  DurationView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 03.08.22.
//

import SwiftUI

struct DurationView: View {
    var duration: TimeInterval = 0
        
    var body: some View {
        Text(NSNumber(value: duration), formatter: DurationFormatter())
    }
}

class DurationFormatter: Formatter {
    let componentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    override func string(for value: Any?) -> String? {
        guard let time = value as? TimeInterval else {
            return nil
        }
        
        guard let formattedString = componentsFormatter.string(from: time) else {
            return nil
        }
        
        return formattedString
    }
}

