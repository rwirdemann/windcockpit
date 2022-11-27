//
//  StartView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 15.07.22.
//

import SwiftUI
import HealthKit

struct StartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var workoutTypes: [HKWorkoutActivityType] = [.cycling, .sailing, .surfingSports]
    
    var body: some View {
        List(workoutTypes) { sessionType in
            VStack {
                NavigationLink(
                    sessionType.name,
                    destination: SessionPagingView(),
                    tag: sessionType,
                    selection: $workoutManager.selectedWorkout
                )
            }
            .padding(
                EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            )
        }
        .listStyle(.carousel)
        .navigationTitle("Windcockpit")
        .onAppear {
            workoutManager.requestAuthorization()
            workoutManager.requestPermission()
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView().environmentObject(WorkoutManager())
    }
}

extension HKWorkoutActivityType: Identifiable {
    public var id: UInt {
        rawValue
    }
    
    var name: String {
        switch self {
        case .cycling:
            return "Wingfoiling"
        case .sailing:
            return "Windsurfing"
        case .surfingSports:
            return "Kitesurfing"
        default:
            return ""
        }
    }
}
