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
            VStack {
                if sessions.isEmpty {
                    Text("No tracked sessions yet")
                } else {
                    List {
                        ForEach(sessions) { s in
                            NavigationLink {
                                SessionDetailView(session: s)
                            } label: {
                                SessionCell(session: s)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Sessions")
            .toolbar {
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
        .onChange(of: connectivityManager.newSessions) {sessions in
            addSessions(sessions: sessions)
        }
    }
        
    private func addSessions(sessions: [Session]?) {
        guard let sessions = sessions else {
            return
        }
        for s in sessions {
            addSession(session: s)
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
    
    private func uploadSessionAndSpot(sessionEntity: SessionEntity) {
        guard let spot = sessionEntity.spot else {
            return
        }
        
        if spot.extid != 0 {
            uploadSession(sessionEntity, spot)
        } else {
            let location = Location(id: 0, name: spot.name ?? "")
            postLocation(
                location: location,
                success: { extid in
                    spot.extid = extid
                    uploadSession(sessionEntity, spot)
                },
                error: { message in
                    self.errorMessage = message
                    showingAlert = true
                }
            )
        }
    }
    
    fileprivate func uploadSession(_ sessionEntity: SessionEntity, _ spot: LocationEntity) {
        postSession(
            session: buildSession(session: sessionEntity, locationId: spot.extid),
            success: { extid in
                sessionEntity.extid = extid
                try! viewContext.save()
            },
            error: { message in
                self.errorMessage = message
                showingAlert = true
            }
        )
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let session = sessions[index]
            viewContext.delete(session)
        }
        try! viewContext.save()
    }

    private func deleteItem(session: SessionEntity) {
        viewContext.delete(session)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
