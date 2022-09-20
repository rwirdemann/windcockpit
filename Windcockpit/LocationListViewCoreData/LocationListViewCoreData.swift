//
//  SpotListViewCoreData.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 08.08.22.
//

import SwiftUI
import CoreData

struct LocationListViewCoreData: View {
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
            }
            .navigationTitle("Spots CoreData")
        }
    }
}
