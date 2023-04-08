//
//  WindcockpitApp.swift
//  Windcockpit WatchKit Extension
//
//  Created by Ralf Wirdemann on 28.07.22.
//

import SwiftUI

@main
struct WindcockpitApp: App {
    @StateObject var sessionManager = SessionTracker()

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                StartView()
            }
            .sheet(isPresented: $sessionManager.showingSummaryView) {
                SessionSummaryView()
            }
            .environmentObject(sessionManager)
        }
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

