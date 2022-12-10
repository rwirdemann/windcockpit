import SwiftUI
import CoreData

struct SessionListView: View {
    @ObservedObject private var connectivityManager = WatchConnectivityManager.shared
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \SessionEntity.date, ascending: false)],
                  animation: .default)
    private var sessions: FetchedResults<SessionEntity>
    
    @FetchRequest(fetchRequest: locationRequest())
    private var locations: FetchedResults<LocationEntity>
    
    @State private var showingAlert = false
    @State private var errorMessage = ""
    
    static func locationRequest() -> NSFetchRequest<LocationEntity> {
        let request: NSFetchRequest<LocationEntity> = LocationEntity.fetchRequest()
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LocationEntity.name, ascending: true)]
        return request
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(sessions) { s in
                    NavigationLink {
                        EditSessionView(s: s)
                    } label: {
                        SessionCell(session: s)
                    }
                    .swipeActions {
                        Button {
                            deleteItem(session: s)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                        Button {
                            uploadSession(sessionEntity: s)
                        } label: {
                            Label("Upload", systemImage: "square.and.arrow.up")
                        }
                        .tint(.blue)
                        .disabled(s.extid != 0)
                    }
                }
            }
            .navigationTitle("Sessions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    NavigationLink(destination: CreateSessionView(),
                                   label: {Image(systemName: "plus")})
                    .disabled(locations.isEmpty)
                }
            }
        }
        .alert(errorMessage, isPresented: $showingAlert)  {
            Button("OK", role: .cancel) {}
        }
        .onChange(of: connectivityManager.newSession) {session in
            addSession(session: session)
        }
    }
    
    private func addSession(session: Session?) {
        guard let session = session else {
            return
        }
        let newItem = SessionEntity(context: viewContext)
        newItem.date = session.date
        newItem.name = session.name
        newItem.maxspeed = session.maxspeed
        newItem.distance = session.distance
        newItem.duration = session.duration
        newItem.spot = findOrCreateLocation(name: session.location)
        try! viewContext.save()
    }
    
    private func findOrCreateLocation(name: String) -> LocationEntity {
        let fetchRequest: NSFetchRequest<LocationEntity>
        fetchRequest = LocationEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "name LIKE %@", name
        )
        do {
            let objects = try viewContext.fetch(fetchRequest)
            if !objects.isEmpty {
                return objects[0]
            }
            return buildNewLocation(name: name)
        } catch {
            return buildNewLocation(name: name)
        }
    }
    
    private func buildNewLocation(name: String) -> LocationEntity {
        let l = LocationEntity(context: viewContext)
        l.name = name
        return l
    }
    
    private func uploadSession(sessionEntity: SessionEntity) {
        guard let spot = sessionEntity.spot else {
            return
        }

        if sessionEntity.spot?.extid != 0 {
            let locationId = sessionEntity.spot?.extid ?? 0
            createSession(session: buildSession(session: sessionEntity, locationId: locationId),
                          callback: self, managedObjectID: sessionEntity.objectID)
        } else {
            let location = Location(id: 0, name: spot.name ?? "")
            createLocation(location: location, callback: self, managedObjectID: spot.objectID, session: sessionEntity)
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

func buildSession(session: SessionEntity, locationId: Int16) -> Session {
    return Session(id: 0,
                   location: "",
                   name: session.name ?? "",
                   date: session.date ?? Date(),
                   distance: session.distance,
                   maxspeed: session.maxspeed,
                   duration: session.duration,
                   locationId: locationId)
}

extension SessionListView: LocationServiceCallback {
    
    func locationSuccess(locationId: Int16, managedObjectID: NSManagedObjectID?, session: SessionEntity) {
        guard let managedObjectID = managedObjectID else {
            return
        }
        
        do {
            let object = try viewContext.existingObject(
                with: managedObjectID
            )
            
            if let location = object as? LocationEntity {
                location.extid = locationId
            }
            
            createSession(session: buildSession(session: session, locationId:locationId), callback: self, managedObjectID: session.objectID)
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func locationError(message: String) {
        self.errorMessage = message
        showingAlert = true
    }
}

extension SessionListView: SessionServiceCallback {
    func success(id: Int16, managedObjectID: NSManagedObjectID?) {
        guard let managedObjectID = managedObjectID else {
            return
        }
        
        do {
            let object = try viewContext.existingObject(
                with: managedObjectID
            )
            
            if let session = object as? SessionEntity {
                session.extid = id
                try viewContext.save()
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
}


private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
