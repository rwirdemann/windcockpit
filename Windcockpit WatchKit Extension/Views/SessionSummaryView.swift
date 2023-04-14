//
//  SessionSummaryView.swift
//  Windcockpit WatchKit App
//
//  Created by Ralf Wirdemann on 30.03.23.
//

import SwiftUI

struct SessionSummaryView: View {
    @EnvironmentObject var sessionManager: SessionTracker
    @Environment(\.dismiss) var dismiss
    
    @State private var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                
                // Session Type
                SummaryMetricView(
                    title: "What",
                    value: sessionManager.selectedSessionType ?? "Wingfoiling"
                )
                .accentColor(Color.blue)

                // Location
                SummaryMetricView(
                    title: "Where",
                    value: sessionManager.currentSession?.location ?? "Unknwon"
                )
                .accentColor(Color.brown)

                // Total time
                SummaryMetricView(
                    title: "Total Time",
                    value: durationFormatter.string(from: sessionManager.workout?.duration ?? 0.0) ?? "")
                    .foregroundStyle(.yellow)

                // Total distance
                SummaryMetricView(
                    title: "Total Distance",
                    value: Measurement(
                        value: sessionManager.workout?.totalDistance?.doubleValue(for: .meter()) ?? 0,
                        unit: UnitLength.meters)
                    .formatted(.measurement(width: .abbreviated,
                                            usage: .road,
                                            numberFormatStyle: .number.precision(.fractionLength(2)))))
                .foregroundStyle(.green)
                
                // Max speed
                SummaryMetricView(
                    title: "Max Speed",
                    value: Measurement(
                        value: sessionManager.currentSession?.maxSpeed ?? 0,
                        unit: UnitSpeed.metersPerSecond
                    ).formatted(
                    )
                )
                .accentColor(Color.orange)

                // Close button
                Button("Done") {
                    dismiss()
                }
            }
            .scenePadding()
        }
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SummaryMetricView: View {
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

struct SessionSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SessionSummaryView()
    }
}
