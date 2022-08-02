//
//  SessionView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 22.05.22.
//

import SwiftUI

struct CreateSessionView: View, EventServiceCallback {
    
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
    @State private var showingAlert = false
    @State private var errorMessage = ""
    
    let sports = ["Wingfoiling", "Windsurfing"]
    
    fileprivate func saveSession() {
        let id = Int.random(in: 1..<1000)
        let session = Session(id: id, location: spot, name: sport, date: date, distance: 0, maxspeed: 0)
        sessionListViewModel.uploadSession(session: session, callback: self)
        presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        Form {
            HStack {
                Text("Spot")
                Spacer()
                Picker("", selection: $spot) {
                    ForEach(sessionListViewModel.locations, id: \.name) {
                        Text($0.name)
                    }
                }.pickerStyle(MenuPickerStyle())
            }

            HStack {
                Text("Wann")
                Spacer()
                DatePicker("", selection: $date, displayedComponents: .date)
                    .environment(\.locale, Locale.init(identifier: "de_DE"))
            }

            HStack {
                Text("Aktivität")
                Spacer()
                Picker("", selection: $sport) {
                    ForEach(sports, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
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
