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
            SessionListView()
                .tabItem {
                    Image(systemName: "list.bullet.circle")
                    Text("Sessions")
                }
            LocationListView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Spots")
                }
            SessionListViewCoreData()
                .tabItem {
                    Image(systemName: "externaldrive")
                    Text("CoreData")
                }
        }
    }
}
