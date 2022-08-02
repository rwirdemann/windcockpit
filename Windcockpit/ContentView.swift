//
//  ContentView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 22.05.22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SessionListView()
                .tabItem {
                    Image(systemName: "list.bullet.circle")
                    Text("Windcockpit")
                }
            Text("Spots")
                .tabItem {
                    Image(systemName: "map")
                    Text("Spots")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
