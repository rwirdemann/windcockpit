//
//  ContentView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 22.05.22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        TabView {
            SessionListViewCoreData()
                .tabItem {
                    Image(systemName: "wind")
                    Text("Sessions")
                }
            SessionListView()
                .tabItem {
                    Image(systemName: "server.rack")
                    Text("Public Timeline")
                }
            LocationListView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Spots")
                }
        }
    }
}
