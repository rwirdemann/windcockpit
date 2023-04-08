//
//  AllSessionsView.swift
//  Windcockpit WatchKit App
//
//  Created by Ralf Wirdemann on 05.04.23.
//

import SwiftUI

struct AllSessionsView: View {
    @EnvironmentObject var sessionManager: SessionTracker
    
    var body: some View {
        List(sessionManager.sessionList, id: \.self) { s in
            let distance = Measurement(
                value: s.distance,
                unit: UnitLength.meters)
            .formatted(.measurement(width: .abbreviated,
                                    usage: .road,
                                    numberFormatStyle: .number.precision(.fractionLength(2))))
            
            Text("\(s.name) \(toString(from: s.date)) \(distance)")
                .font(.footnote)
        }
        .navigationTitle("All Sessions")
    }
}

struct AllSessionsView_Previews: PreviewProvider {
    static var previews: some View {
        AllSessionsView()
    }
}
