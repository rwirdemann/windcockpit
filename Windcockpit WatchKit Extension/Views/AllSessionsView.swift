//
//  AllSessionsView.swift
//  Windcockpit WatchKit App
//
//  Created by Ralf Wirdemann on 05.04.23.
//

import SwiftUI

struct AllSessionsView: View {
    @EnvironmentObject var sessionTracker: SessionTracker
    
    var body: some View {
        VStack {
            Button("Sync") {
                if WatchConnectivityManager.shared.isConnected() {
                    sessionTracker.sync()
                    sessionTracker.sessionList.removeAll()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .disabled(sessionTracker.sessionList.isEmpty || !WatchConnectivityManager.shared.isConnected())
            List(sessionTracker.sessionList, id: \.self) { s in
                let distance = Measurement(
                    value: s.distance,
                    unit: UnitLength.meters)
                    .formatted(.measurement(width: .abbreviated,
                                            usage: .road,
                                            numberFormatStyle: .number.precision(.fractionLength(2))))
                
                Text("\(s.name), \(s.location), \(toString(from: s.date)) \(distance)")
                    .font(.footnote)
            }
        }
        .navigationTitle("All Sessions")
    }
}

struct AllSessionsView_Previews: PreviewProvider {
    static var previews: some View {
        AllSessionsView()
    }
}
