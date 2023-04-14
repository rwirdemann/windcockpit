//
//  AllSessionsView.swift
//  Windcockpit WatchKit App
//
//  Created by Ralf Wirdemann on 05.04.23.
//

import SwiftUI

struct AllSessionsView: View {
    @EnvironmentObject var sessionTracker: SessionTracker
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \SessionEntity.date, ascending: false)],
                  animation: .default)
    private var sessions: FetchedResults<SessionEntity>
    
    @State private var showingAlert = false
    @State private var message = ""

    var body: some View {
        VStack {
            Button("Sync with iPhone") {
                sync()
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .disabled(sessions.isEmpty)
            List(sessions, id: \.self) { s in
                let distance = Measurement(
                    value: s.distance,
                    unit: UnitLength.meters)
                    .formatted(.measurement(width: .abbreviated,
                                            usage: .road,
                                            numberFormatStyle: .number.precision(.fractionLength(2))))
                
                Text("\(s.name!), \(s.location!), \(toString(from: s.date!)) \(distance)")
                    .font(.footnote)
            }
        }
        .navigationTitle("All Sessions")
        .alert(message, isPresented: $showingAlert)  {
            Button("OK", role: .cancel) {}
        }
    }
    
    func sync() {
        if !WatchConnectivityManager.shared.isConnected() {
            message = "iPhone not connected"
            showingAlert = true
            return
        }
        for s in sessions {
            let session = Session(
                id: 0,
                location: s.location!,
                name: s.name!,
                date: s.date!,
                distance: s.distance,
                maxspeed: s.maxSpeed,
                duration: s.duration,
                locationId: 0
            )
            WatchConnectivityManager.shared.send(session)
            viewContext.delete(s)
        }
        try! viewContext.save()
    }
}
