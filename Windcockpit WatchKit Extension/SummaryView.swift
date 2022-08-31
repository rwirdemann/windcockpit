//
//  SummaryView.swift
//  WindcockpitWatch WatchKit Extension
//
//  Created by Ralf Wirdemann on 17.07.22.
//

import SwiftUI
import CoreData

struct SummaryView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    @Environment(\.dismiss) var dismiss
    @State private var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    @State private var showingAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        if workoutManager.workout == nil {
            ProgressView("Saving session")
                .navigationBarHidden(true)
        } else {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    SummaryMetricvView(
                        title: "Total Time",
                        value: durationFormatter.string(from: workoutManager.workout?.duration  ?? 0.0) ?? "")
                    .accentColor(Color.yellow)
                    SummaryMetricvView(
                        title: "Total Distance",
                        value: Measurement(
                            value: workoutManager.workout?.totalDistance?.doubleValue(for: .meter()) ?? 0,
                            unit: UnitLength.meters
                        ).formatted(
                            .measurement(width: .abbreviated,
                                         usage: .road)
                        )
                    )
                    .accentColor(Color.green)
                    SummaryMetricvView(
                        title: "Max Speed",
                        value: Measurement(
                            value: workoutManager.maxSpeed,
                            unit: UnitSpeed.metersPerSecond
                        ).formatted(
                        )
                    )
                    .accentColor(Color.red)

                    let formatter = DurationFormatter()
                    let duration = formatter.string(for: workoutManager.builder?.elapsedTime ?? 0) ?? "00:00:00"
                    SummaryMetricvView(
                        title: "Duration",
                        value: duration
                    )
                    .accentColor(Color.mint)

                    
                    Button("Sync Session") {
                        WatchConnectivityManager.shared.send(buildSession())
                        DispatchQueue.main.async {
                            dismiss()
                        }
                    }
                    .disabled(!WatchConnectivityManager.shared.isConnected())
                    
                    Button("Upload Session") {
                        createSession(session: buildSession(), callback: self, managedObjectID:nil)
                    }
                }
                .alert(errorMessage, isPresented: $showingAlert)  {
                    Button("OK", role: .cancel) {}
                }
                .scenePadding()
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func buildSession() -> Session {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de")
        formatter.dateFormat = "d. MMMM y, HH:mm"
        let location = workoutManager.currentPlacemark?.locality ?? "New: \(formatter.string(from: Date()))"
        let dist = workoutManager.workout?.totalDistance?.doubleValue(for: .meter()) ?? 0
        let duration = workoutManager.builder?.elapsedTime ?? 0
        return Session(id: 0,
                        location: location,
                        name: "Wingfoiling",
                        date: Date(),
                        distance: dist,
                        maxspeed: workoutManager.maxSpeed,
                        duration: duration)
        
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}

struct SummaryMetricvView: View {
    var title: String
    var value: String
    
    var body: some View {
        Text(title)
        Text(value)
            .font(.system(.title2, design: .rounded)
                .lowercaseSmallCaps()
            )
            .foregroundColor(.accentColor)
        Divider()
    }
}

extension SummaryView: SessionServiceCallback {
    func success(id: Int, managedObjectID: NSManagedObjectID?) {
        DispatchQueue.main.async {
            dismiss()
        }
    }
    
    func error(message: String) {
        self.errorMessage = message
        showingAlert = true
    }
}
