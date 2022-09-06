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
    
    var workoutTypes: [HKWorkoutActivityType] = [.cycling, .sailing]
    
    var body: some View {
        NavigationLink(
            "Start session",
            destination: SessionPagingView(),
            tag: .cycling,
            selection: $workoutManager.selectedWorkout
        )
        .onAppear {
            workoutManager.requestAuthorization()
            workoutManager.requestPermission()
        }
        .navigationTitle("Windcockpit")
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
        default:
            return ""
        }
    }
}
