import SwiftUI
import CoreData

struct SessionListView: View, SessionServiceCallback {
    @ObservedObject private var connectivityManager = WatchConnectivityManager.shared
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SessionEntity.date, ascending: false)],
        animation: .default)
    private var items: FetchedResults<SessionEntity>
    
    @State private var showingAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        EditSessionView(s: item)
                    } label: {
                        SessionCell(session: item)
                    }
                    .swipeActions {
                        Button {
                            deleteItem(session: item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                        Button {
                            uploadSession(sessionEntity: item)
                        } label: {
                            Label("Upload", systemImage: "square.and.arrow.up")
                        }
                        .tint(.blue)
                        .disabled(item.published)
                    }
                }
            }
            .navigationTitle("My Sessions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    NavigationLink(destination: CreateSessionView(),
                                   label: {Image(systemName: "plus")})
                }
            }
        }
        .alert(errorMessage, isPresented: $showingAlert)  {
            Button("OK", role: .cancel) {}
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
        newItem.name = session.name
        newItem.maxspeed = session.maxspeed
        newItem.distance = session.distance
        newItem.duration = session.duration
        newItem.published = false
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func uploadSession(sessionEntity: SessionEntity) {
        let name = sessionEntity.name ?? ""
        let date = sessionEntity.date ?? Date()
        let session = Session(id: 0,
                              location: "",
                              name: name,
                              date: date,
                              distance: sessionEntity.distance,
                              maxspeed: sessionEntity.maxspeed,
                              duration: sessionEntity.duration,
                              locationId: 0)
        createSession(session: session, callback: self, managedObjectID: sessionEntity.objectID)
    }
    
    func success(id: Int, managedObjectID: NSManagedObjectID?) {
        guard let managedObjectID = managedObjectID else {
            return
        }
        
        do {
            let object = try viewContext.existingObject(
                with: managedObjectID
            )
            
            if let session = object as? SessionEntity {
                session.cid = Int32(id)
                session.published = true
            }
            
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func error(message: String) {
        self.errorMessage = message
        showingAlert = true
    }
    
    private func addItem() {
        withAnimation {
            let newItem = SessionEntity(context: viewContext)
            newItem.date = Date()
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
