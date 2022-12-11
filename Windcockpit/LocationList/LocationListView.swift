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
                    VStack {
                        Text(l.name ?? "unknown")
                    }
                    .deleteDisabled(l.sessions != nil ? l.sessions!.count > 0 : false)
                }
                .onDelete(perform: self.deleteItem)
            }
            .navigationTitle("Spots")
            .toolbar {
                ToolbarItem {
                    NavigationLink(destination: CreateLocationView(),
                                   label: {Image(systemName: "plus")})
                }
            }            
        }
    }
    
    private func sessionsAsString(sessions: NSSet?) -> String {
        guard let session = sessions else {
            return ""
        }
        
        for case let s as SessionEntity in session  {
            return s.name ?? ""
        }
        
        return ""
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

extension NSSet {
  func toArray<T>() -> [T] {
    let array = self.map({ $0 as! T})
    return array
  }
}
