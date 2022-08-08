//
//  SpotListView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 08.08.22.
//

import SwiftUI

struct LocationListView: View {
    @StateObject private var viewModel = LocationListModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.locations) { l in
                    Text(l.name)
                }
            }
            .navigationTitle("Spots")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.loadLocations()
        }
    }
}
