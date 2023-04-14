//
//  WindcockpitApp.swift
//  Windcockpit WatchKit Extension
//
//  Created by Ralf Wirdemann on 28.07.22.
//

import SwiftUI

@main
struct WindcockpitApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var sessionManager = SessionTracker()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                SessionSelectView()
            }
            .sheet(isPresented: $sessionManager.showingSummaryView) {
                SessionSummaryView()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(sessionManager)
        }
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
