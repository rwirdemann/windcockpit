//
//  SessionSummaryView.swift
//  Windcockpit WatchKit App
//
//  Created by Ralf Wirdemann on 30.03.23.
//

import SwiftUI

struct SessionSummaryView: View {
    @EnvironmentObject var sessionManager: SessionManager
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
                SummaryMetricvView(
                    title: "What",
                    value: sessionManager.selectedSessionType ?? "Wingfoiling"
                )
                .accentColor(Color.blue)

                // Total time
                SummaryMetricvView(
                    title: "Total Time",
                    value: durationFormatter.string(from: sessionManager.elapsedTime()) ?? "")
                .accentColor(Color.yellow)

                // Total distance
                SummaryMetricvView(
                    title: "Total Distance",
                    value: sessionManager.distance.formatted(.measurement(width: .abbreviated, usage: .road))
                )
                .accentColor(Color.green)

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

struct SessionSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SessionSummaryView()
    }
}
