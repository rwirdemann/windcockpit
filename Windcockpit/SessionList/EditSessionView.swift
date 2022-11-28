//
//  EditSessionView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 28.06.22.
//

import SwiftUI
import CoreData

struct EditSessionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.editMode) private var editMode
    var session: SessionEntity
    
    @State private var selectedSpot: LocationEntity?
    @State private var date: Date
    @State private var sport: String
    @State private var distance: Double
    @State private var maxspeed: Double
    @State private var duration: Double
    
    @State private var showingAlert = false
    @State private var errorMessage = ""
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LocationEntity.name, ascending: true)],
        animation: .default)
    private var spots: FetchedResults<LocationEntity>
    
    let sports = ["Wingfoiling", "Windsurfing", "Kitesurfing"]
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    init(s: SessionEntity) {
        self.session = s
        
        _date = State(initialValue: s.date ?? Date())
        _sport = State(initialValue: s.name ?? "")
        _distance = State(initialValue: s.distance)
        _maxspeed = State(initialValue: s.maxspeed)
        _duration = State(initialValue: s.duration)
        _selectedSpot = State(initialValue: s.spot)
    }
    
    var body: some View {
        Form {
            HStack {
                Text("Spot")
                Spacer()
                if editMode?.wrappedValue.isEditing == true {
                    Picker("", selection: $selectedSpot) {
                        ForEach(spots) { location in
                            Text(location.name!)
                                .tag(Optional(location))
                        }
                    }.pickerStyle(MenuPickerStyle())
                } else {
                    Text(session.spot?.name ?? "")
                }
            }
            
            HStack {
                Text("When")
                Spacer()
                if editMode?.wrappedValue.isEditing == true {
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .environment(\.locale, Locale.init(identifier: "de_DE"))
                } else {
                    Text(toString(from: session.date ?? Date()))
                        .font(.subheadline)
                }
            }
            
            HStack {
                Text("Sport")
                Spacer()
                if editMode?.wrappedValue.isEditing == true {
                    Picker("", selection: $sport) {
                        ForEach(sports, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                } else {
                    Text(session.name ?? "")
                        .font(.subheadline)
                }
            }
            
            let distance = Measurement(
                value: distance,
                unit: UnitLength.meters
            ).formatted(
                .measurement(width: .abbreviated,
                             usage: .road)
            )
            HStack {
                Text("Distance")
                Spacer()
                if editMode?.wrappedValue.isEditing == true {
                    TextField("Distance", value: $distance, formatter: formatter)
                        .multilineTextAlignment(.trailing)
                } else {
                    Text(distance)
                        .font(.subheadline)
                }
            }
            
            
            let maxSpeed = Measurement(
                value: maxspeed,
                unit: UnitSpeed.metersPerSecond
            ).formatted(
            )
            HStack {
                Text("Max")
                Spacer()
                if editMode?.wrappedValue.isEditing == true {
                    TextField("Max speed", value: $maxspeed, formatter: formatter)
                        .multilineTextAlignment(.trailing)
                } else {
                    Text(maxSpeed)
                        .font(.subheadline)
                }
            }
            HStack {
                Text("Duration")
                Spacer()
                if editMode?.wrappedValue.isEditing == true {
                    TextField("Duration", value: $duration, formatter: Formatters.number)
                        .multilineTextAlignment(.trailing)
                } else {
                    DurationView(duration: duration)
                        .font(.subheadline)
                }
            }
            
        }
        .alert(errorMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
            }
            
        }
        .toolbar {
            EditButton()
        }
        .navigationTitle("Your Session")
        .onChange(of: editMode!.wrappedValue, perform: { value in
            if !value.isEditing {
                session.name = sport
                session.date = date
                session.duration = duration
                session.maxspeed = maxspeed
                session.distance = distance
                session.spot = selectedSpot
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
                
                if session.published {
                    let s = Session(id: Int(session.cid),
                                    location: session.spot?.name ?? "",
                                    name: session.name ?? "",
                                    date: session.date ?? Date(),
                                    distance: session.distance,
                                    maxspeed: session.maxspeed,
                                    duration: session.duration,
                                    locationId: 0)
                    updateSession(session: s, callback: self)
                }                
            }
        })
    }
}

extension EditSessionView: SessionServiceCallback {
    func success(id: Int, managedObjectID: NSManagedObjectID?) {
    }
    
    func error(message: String) {
    }
}
