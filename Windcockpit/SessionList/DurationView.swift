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
