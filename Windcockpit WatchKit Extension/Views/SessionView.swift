//
//  SessionView.swift
//  Windcockpit WatchKit App
//
//  Created by Ralf Wirdemann on 30.03.23.
//

import SwiftUI

struct SessionView: View {
    @EnvironmentObject var sessionManager: SessionTracker

    var body: some View {
        TimelineView(
            SessionTimelineSchedule(from: sessionManager.builder?.startDate ?? Date())
        ) { context in
            VStack(alignment: .leading) {

                // Time
                ElapsedTimeView(
                    elapsedTime: sessionManager.builder?.elapsedTime(at: context.date) ?? 0,
                    showSubseconds: context.cadence == .live)
                .foregroundColor(Color.yellow)

                // Speed
                Text(
                    Measurement(
                        value: sessionManager.currentSpeed(),
                        unit: UnitSpeed.metersPerSecond
                    ).formatted(
                    )
                )

                // Max speed
                Text(
                    Measurement(
                        value: sessionManager.currentSession?.maxSpeed ?? 0,
                        unit: UnitSpeed.metersPerSecond
                    ).formatted(
                    )
                )
                .foregroundColor(.orange)

                // Distance
                Text(Measurement(value: sessionManager.hkDistance, unit: UnitLength.meters).formatted(.measurement(width: .abbreviated, usage: .road)))
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
