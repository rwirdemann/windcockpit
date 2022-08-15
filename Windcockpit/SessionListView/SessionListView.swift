//
//  RedOneView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 22.05.22.
//

import SwiftUI
import CoreData

struct SessionListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // The SessionListViewModel is an observable that publishes its session list. Since we reference
    // this model as StateObject we can be sure that this model stays alive even when the view gets
    // updated. StateObject makes also sure the this view will be informed when the published states
    // changes
    @StateObject private var viewModel = SessionListViewModel()
        
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.sessions) { session in
                    NavigationLink {
                        EditSessionView(session: session)
                    } label: {
                        SessionCell(session: session)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Sessions")
            .toolbar {
                NavigationLink(destination: CreateSessionView(),
                               label: {Image(systemName: "plus")})
            }
        }
        .onAppear {
            viewModel.loadSessions(viewContext: viewContext)
            viewModel.loadSpots()
        }
        .environmentObject(viewModel)
    }
    
    func delete(at offsets: IndexSet) {
        viewModel.removeSession(index: offsets.first!)
    }
}
