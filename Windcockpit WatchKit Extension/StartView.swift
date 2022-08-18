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
        VStack {
            Button("Hello World!", action: {
                let s = Session(id:0,
                                location: "Hansholm",
                                name: "Wingfoiling",
                                date: Date(),
                                distance: 0,
                                maxspeed: 0,
                                duration: 0)
                WatchConnectivityManager.shared.send(s)
            })
            List(workoutTypes) { workoutType in
                NavigationLink(
                    workoutType.name,
                    destination: SessionPagingView(),
                    tag: workoutType,
                    selection: $workoutManager.selectedWorkout
                )
            }.padding(
                EdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 10)
            )
            .listStyle(.carousel)
            .navigationTitle("Windcockpit")
            .onAppear {
                workoutManager.requestAuthorization()
                workoutManager.requestPermission()
            }
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
        default:
            return ""
        }
    }
}
