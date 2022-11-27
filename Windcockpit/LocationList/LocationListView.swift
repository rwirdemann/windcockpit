//
//  LocationListView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 08.08.22.
//

import SwiftUI
import CoreData

struct LocationListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LocationEntity.name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<LocationEntity>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { l in
                    Text(l.name ?? "unknown")
                }
                .onDelete(perform: self.deleteItem)
            }
            .navigationTitle("Spots")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    NavigationLink(destination: CreateLocationView(),
                                   label: {Image(systemName: "plus")})
                }
            }
            
        }
    }
    
    private func deleteItem(at indexSet: IndexSet) {
        for index in indexSet {
            let l = items[index]
            viewContext.delete(l)
            do {
                try viewContext.save()
            } catch {
            }
        }
    }
}
