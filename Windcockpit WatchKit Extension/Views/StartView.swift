//
//  StartView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 15.07.22.
//

import SwiftUI
import HealthKit

struct StartView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    var sessionTypes: [String] = ["Wingfoiling", "Windsurfing"]
    
    var body: some View {
        List(sessionTypes, id: \.self) { sessionType in
            NavigationLink(
                sessionType,
                destination: SessionPagingView(),
                tag: sessionType,
                selection: $sessionManager.selectedSessionType
            ).padding(
                EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5)
            )
        }
        .listStyle(.carousel)
        .navigationTitle("Windcockpit")
        .onAppear {
            sessionManager.requestLocationManagerPermission()
        }
    }
}
