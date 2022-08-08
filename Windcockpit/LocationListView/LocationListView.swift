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
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.loadLocations(errorHandler: self)
        }
    }
    
    func delete(at offsets: IndexSet) {
        viewModel.deleteLocation(index: offsets.first!, errorHandler: self)
    }
}

extension LocationListView: ErrorHandler {
    func error(message: String) {
        errorMessage = message
        showingAlert = true
    }
}

