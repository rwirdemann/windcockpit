//
//  ContentView.swift
//  CoreSample
//
//  Created by Ralf Wirdemann on 10.08.22.
//

import SwiftUI
import CoreData

struct SessionListViewCoreData: View {
    @ObservedObject private var connectivityManager = WatchConnectivityManager.shared
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SessionEntity.date, ascending: false)],
        animation: .default)
    private var items: FetchedResults<SessionEntity>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                   NavigationLink {
                       let published = item.published ? "published" : "local"
                        Text("Item at \(item.date!, formatter: itemFormatter): \(published)")
                    } label: {
                        SessionCellCoreData(session: item)
                    }
                    .swipeActions {
                        Button {
                            deleteItem(session: item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                        Button {
                            uploadSession(session: item)
                        } label: {
                            Label("Upload", systemImage: "square.and.arrow.up")
                        }
                        .tint(.blue)
                        .disabled(item.published)
                    }
                }
            }
            .navigationTitle("CoreData")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
        .onChange(of: connectivityManager.newSession) {session in
            addItem(session: session)
        }
    }
    
    private func addItem(session: Session?) {
        guard let session = session else {
            return
        }
        let newItem = SessionEntity(context: viewContext)
        newItem.date = session.date
        newItem.location = session.location
        newItem.name = session.name
        newItem.published = false
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func uploadSession(session: SessionEntity) {
        session.published = true
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = SessionEntity(context: viewContext)
            newItem.date = Date()
            newItem.location = "Hanstholm"
            newItem.name = "Wingfoil"
            newItem.published = false
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItem(session: SessionEntity) {
        withAnimation {
            viewContext.delete(session)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SessionListViewCoreData().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
