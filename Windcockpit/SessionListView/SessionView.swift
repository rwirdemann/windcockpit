//
//  SessionView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 22.05.22.
//

import SwiftUI

struct SessionView: View, EventServiceCallback {

    func success(event: Session) {
        sessionListViewModel.loadSessions()
    }
    
    func error(message: String) {
        self.errorMessage = message
        showingAlert = true
    }
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var sessionListViewModel: SessionListViewModel
    @State private var spot = ""
    @State private var sport = "Wingding"
    @State private var date = Date()
    @State private var distance = 0.0
    @State private var maxSpeed = 0.0
    @State private var showingAlert = false
    @State private var errorMessage = ""

    let sports = ["Wingfoiling", "Windsurfing"]
    
    fileprivate func saveSession() {
        let id = Int.random(in: 1..<1000)
        let session = Session(id: id, location: spot, name: sport, date: date, distance: distance, maxspeed: maxSpeed)
        sessionListViewModel.uploadSession(session: session, callback: self)
        presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        Form {
            Section(header: Text("Session Daten")) {
                Section {
                    Picker("Sport", selection: $sport) {
                        ForEach(sports, id: \.self) {
                            Text($0)
                        }
                    }
                }
                Section {
                    Picker("Spot", selection: $spot) {
                        ForEach(sessionListViewModel.locations, id: \.name) {
                            Text($0.name)
                        }
                    }
                }
                DatePicker("Wann", selection: $date, displayedComponents: .date)
                    .environment(\.locale, Locale.init(identifier: "de_DE"))
                
                let formatter: NumberFormatter = {
                      let formatter = NumberFormatter()
                      formatter.numberStyle = .decimal
                      return formatter
                  }()
                HStack(spacing: 10) {
                    Text("Distance")
                    Spacer()
                    TextField("Distance", value: $distance, formatter: formatter)
                }
                HStack(spacing: 10) {
                    Text("Max Speed")
                    Spacer()
                    TextField("Maxspeed", value: $maxSpeed, formatter: formatter)
                }
            }
        }
        .alert(errorMessage, isPresented: $showingAlert)  {
            Button("OK", role: .cancel) {}
        }
        .navigationTitle("Neue Session")
        .toolbar{
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Save", action : saveSession)
                    .disabled(self.spot.isEmpty)
            }
        }
    }
}

struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView()
    }
}
