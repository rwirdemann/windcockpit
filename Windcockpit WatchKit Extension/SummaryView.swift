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
                        title: "What",
                        value: workoutManager.selectedWorkout?.name ?? ""
                    )
                    .accentColor(Color.blue)

                    SummaryMetricvView(
                        title: "Where",
                        value: workoutManager.location
                    )
                    .accentColor(Color.brown)

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
                    
                    Button("Done") {
                        DispatchQueue.main.async {
                            dismiss()
                        }
                    }
                    .disabled(!WatchConnectivityManager.shared.isConnected())
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
        let dist = workoutManager.workout?.totalDistance?.doubleValue(for: .meter()) ?? 0
        let duration = workoutManager.builder?.elapsedTime ?? 0
        let sport = workoutManager.selectedWorkout?.name ?? ""
        return Session(id: 0,
                       location: workoutManager.location,
                       name: sport,
                       date: Date(),
                       distance: dist,
                       maxspeed: workoutManager.maxSpeed,
                       duration: duration,
                       locationId: 0
        )
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
            )
            .foregroundColor(.accentColor)
        Divider()
    }
}
