//
//  SessionDetail.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 28.06.22.
//

import SwiftUI

struct EditSessionView: View, EventServiceCallback {
    @EnvironmentObject var sessionListViewModel: SessionListViewModel
    @Environment(\.editMode) private var editMode
    @State var session: Session
    @State private var showingAlert = false
    @State private var errorMessage = ""
    
    let sports = ["Wingfoiling", "Windsurfing"]
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    func success(event: Session) {
    }
    
    func error(message: String) {
        self.errorMessage = message
        showingAlert = true
    }
    
    var body: some View {        
        Form {
            HStack {
                Text("Spot")
                Spacer()
                if editMode?.wrappedValue.isEditing == true {
                    Picker("Spot", selection: $session.location) {
                        ForEach(sessionListViewModel.locations, id: \.name) {
                            Text($0.name)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                } else {
                    Text(session.location)
                }
            }
            
            HStack {
                Text("Wann")
                Spacer()
                if editMode?.wrappedValue.isEditing == true {
                    DatePicker("", selection: $session.date, displayedComponents: .date)
                        .environment(\.locale, Locale.init(identifier: "de_DE"))
                } else {
                    Text(toString(from: session.date))
                        .font(.subheadline)
                }
            }
            
            HStack {
                Text("Aktivität")
                Spacer()
                if editMode?.wrappedValue.isEditing == true {
                    Picker("", selection: $session.name) {
                        ForEach(sports, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                } else {
                    Text(session.name)
                        .font(.subheadline)
                }
            }
            
            let distance = Measurement(
                value: session.distance,
                unit: UnitLength.meters
            ).formatted(
                .measurement(width: .abbreviated,
                             usage: .road)
            )
            HStack {
                Text("Distanz")
                Spacer()
                if editMode?.wrappedValue.isEditing == true {
                    TextField("Max speed", value: $session.distance, formatter: formatter)
                        .multilineTextAlignment(.trailing)
                } else {
                    Text(distance)
                        .font(.subheadline)
                }
            }
            
            
            let maxSpeed = Measurement(
                value: session.maxspeed,
                unit: UnitSpeed.metersPerSecond
            ).formatted(
            )
            HStack {
                Text("Max")
                Spacer()
                if editMode?.wrappedValue.isEditing == true {
                    TextField("Max speed", value: $session.maxspeed, formatter: formatter)
                        .multilineTextAlignment(.trailing)
                } else {
                    Text(maxSpeed)
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
                updateSession(session: session, callback: self)
                sessionListViewModel.replace(session: session)
            }
        })
    }
}
