//
//  WindcockpitApp.swift
//  Windcockpit WatchKit Extension
//
//  Created by Ralf Wirdemann on 28.07.22.
//

import SwiftUI

@main
struct WindcockpitApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
