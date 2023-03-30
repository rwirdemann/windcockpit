//
//  SessionView.swift
//  Windcockpit WatchKit App
//
//  Created by Ralf Wirdemann on 30.03.23.
//

import SwiftUI

struct SessionView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        TimelineView(
            SessionTimelineSchedule(from: sessionManager.startDate ?? Date())
        ) { context in
            VStack(alignment: .leading) {

                // Time
                ElapsedTimeView(
                    elapsedTime: sessionManager.elapsedTime(),
                    showSubseconds: context.cadence == .live)
                .foregroundColor(Color.yellow)

                // Distance
                Text(
                    Measurement(
                        value: sessionManager.distance,
                        unit: UnitLength.meters
                    ).formatted(
                        .measurement(width: .abbreviated,
                                     usage: .road)
                    )
                )
                .foregroundColor(Color.green)
            }
            .font(.system(.title, design: .rounded)
                .monospacedDigit()
                .lowercaseSmallCaps()
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .ignoresSafeArea(edges: .bottom)
            .scenePadding()
        }
    }
}

struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView()
    }
}

private struct SessionTimelineSchedule: TimelineSchedule {
    var startDate: Date
    
    init(from startDate: Date) {
        self.startDate = startDate
    }
    
    func entries(from startDate: Date, mode: TimelineScheduleMode) -> PeriodicTimelineSchedule.Entries {
        PeriodicTimelineSchedule(
            from: self.startDate,
            by: (mode == .lowFrequency ? 1.0 : 1.0 / 30.0)).entries(
                from: startDate, mode: mode
            )
    }
}
