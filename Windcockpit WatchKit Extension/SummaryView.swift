//
//  SummaryView.swift
//  WindcockpitWatch WatchKit Extension
//
//  Created by Ralf Wirdemann on 17.07.22.
//

import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var locationViewModel: LocationViewModel
    
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
                            value: locationViewModel.maxSpeed,
                            unit: UnitSpeed.metersPerSecond
                        ).formatted(
                        )
                    )
                    .accentColor(Color.cyan)
                    SummaryMetricvView(
                        title: "Duration",
                        value: Measurement(
                            value: workoutManager.builder?.elapsedTime ?? 0,
                            unit: UnitDuration.seconds
                        ).formatted(
                        )
                    )
                    .accentColor(Color.mint)
                    Button("Upload Session") {
                        let formatter = DateFormatter()
                        formatter.locale = Locale(identifier: "de")
                        formatter.dateFormat = "d. MMMM y, HH:mm"
                        let location = locationViewModel.currentPlacemark?.locality ?? "New: \(formatter.string(from: Date()))"
                        let dist = workoutManager.workout?.totalDistance?.doubleValue(for: .meter()) ?? 0
                        let duration = workoutManager.builder?.elapsedTime ?? 0
                        let s = Session(id: 1,
                                        location: location,
                                        name: "Wingfoiling",
                                        date: Date(),
                                        distance: dist,
                                        maxspeed: locationViewModel.maxSpeed,
                                        duration: duration)
                        createSession(session: s, callback: self)
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

extension SummaryView: EventServiceCallback {
    func success(event: Session) {
        DispatchQueue.main.async {
            dismiss()
        }
    }
    
    func error(message: String) {
        self.errorMessage = message
        showingAlert = true
    }
}
