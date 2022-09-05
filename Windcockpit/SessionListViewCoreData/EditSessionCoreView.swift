//
//  EditSessionCoreView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 28.06.22.
//

import SwiftUI
import CoreData

struct EditSessionCoreView: View {
    @Environment(\.editMode) private var editMode
    var session: SessionEntity
    @EnvironmentObject var spotListModel: SpotListModel

    @State private var location: String
    @State private var date: Date
    @State private var sport: String
    @State private var distance: Double
    @State private var maxspeed: Double
    @State private var duration: Double

    @State private var showingAlert = false
    @State private var errorMessage = ""

    let sports = ["Wingfoiling", "Windsurfing"]

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    init(s: SessionEntity) {
        self.session = s

        _location = State(initialValue: s.location ?? "")
        _date = State(initialValue: s.date ?? Date())
        _sport = State(initialValue: s.name ?? "")
        _distance = State(initialValue: s.distance)
        _maxspeed = State(initialValue: s.maxspeed)
        _duration = State(initialValue: s.duration)
    }

    var body: some View {
        Form {
            HStack {
                Text("Spot")
                Spacer()
                if editMode?.wrappedValue.isEditing == true {
                    Picker("Spot", selection: $location) {
                        ForEach(spotListModel.locations, id: \.name) {
                            Text($0.name)
                        }
                    }
                            .pickerStyle(MenuPickerStyle())
                } else {
                    Text(session.location ?? "")
                }
            }

            HStack {
                Text("Wann")
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
                Text("Aktivität")
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
                Text("Distanz")
                Spacer()
                if editMode?.wrappedValue.isEditing == true {
                    TextField("Distanz", value: $distance, formatter: formatter)
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
                Text("Dauer")
                Spacer()
                if editMode?.wrappedValue.isEditing == true {
                    TextField("Dauer", value: $duration, formatter: Formatters.number)
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
                .navigationTitle("Deine Session")
                .onChange(of: editMode!.wrappedValue, perform: { value in
                    if !value.isEditing {
                        session.location = location
                        session.name = sport
                        session.duration = duration
                        session.maxspeed = maxspeed
                        session.distance = distance
                        if session.published {
                            let s = Session(id: Int(session.cid),
                                    location: session.location ?? "",
                                    name: session.name ?? "",
                                    date: session.date ?? Date(),
                                    distance: session.distance,
                                    maxspeed: session.maxspeed,
                                    duration: session.duration)
                            updateSession(session: s, callback: self)
                        }
                    }
                })
    }
}

extension EditSessionCoreView: SessionServiceCallback {
    func success(id: Int, managedObjectID: NSManagedObjectID?) {
    }

    func error(message: String) {
    }
}
