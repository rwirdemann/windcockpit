//
//  WindcockpitApp.swift
//  Windcockpit WatchKit Extension
//
//  Created by Ralf Wirdemann on 28.07.22.
//

import SwiftUI

@main
struct WindcockpitApp: App {
    @StateObject var workoutManager = WorkoutManager()
    @StateObject var locationViewModel = LocationViewModel()

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                StartView()
            }
            .sheet(isPresented: $workoutManager.showingSummaryView) {
                SummaryView()
            }
            .environmentObject(workoutManager)
            .environmentObject(locationViewModel)
        }
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

