//
//  WindcockpitApp.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 28.07.22.
//

import SwiftUI

@main
struct WindcockpitApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
