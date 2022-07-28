//
//  SessionDetail.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 28.06.22.
//

import SwiftUI

struct SessionDetail: View, EventServiceCallback {
    @EnvironmentObject var sessionListViewModel: SessionListViewModel
    @Environment(\.editMode) private var editMode
    @State var session: Session
    @State private var showingAlert = false
    @State private var errorMessage = ""

    func success(event: Session) {
    }

    func error(message: String) {
        self.errorMessage = message
        showingAlert = true
    }

    var body: some View {
        Form {
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
            Text(toString(from: session.date))
                    .font(.subheadline)
            Text(session.name)
                    .font(.subheadline)

            let distance = Measurement(
                    value: session.distance,
                    unit: UnitLength.meters
            ).formatted(
                    .measurement(width: .abbreviated,
                            usage: .road)
            )
            Text("Distance: \(distance)")
                    .font(.subheadline)
        }
                .alert(errorMessage, isPresented: $showingAlert) {
                    Button("OK", role: .cancel) {
                    }

                }
                .toolbar {
                    EditButton()
                }
                .onChange(of: editMode!.wrappedValue, perform: { value in
                    if !value.isEditing {
                        updateSession(session: session, callback: self)
                        sessionListViewModel.replace(session: session)
                    }
                })
    }
}

struct SessionDetail_Previews: PreviewProvider {
    static var previews: some View {
        SessionDetail(session: Session(id: 1, location: "Heiligenhafen", name: "Wingding", date: Date(), distance: 0))
    }
}
