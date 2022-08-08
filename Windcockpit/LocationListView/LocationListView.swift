//
//  SpotListView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 08.08.22.
//

import SwiftUI

struct LocationListView: View {
    @StateObject private var viewModel = LocationListModel()
    @State private var showingAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.locations) { l in
                    Text(l.name)
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Spots")
        }
        .alert(errorMessage, isPresented: $showingAlert)  {
            Button("OK", role: .cancel) {}
        }
        .onAppear {
            viewModel.loadLocations(cb: self)
        }
    }
    
    func delete(at offsets: IndexSet) {
        viewModel.deleteLocation(index: offsets.first!, cb: self)
    }
}

extension LocationListView: LocationServiceCallback {
    func success(locations: [Location]) {
    }
    
    func error(message: String) {
        errorMessage = message
        showingAlert = true
    }
}

