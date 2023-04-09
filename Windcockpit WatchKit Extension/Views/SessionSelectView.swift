//
//  StartView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 15.07.22.
//

import SwiftUI
import HealthKit

struct SessionSelectView: View {
    @EnvironmentObject var sessionManager: SessionTracker
    
    var sessionTypes: [String] = ["Wingfoiling", "Windsurfing", "Kitesurfing", "Kitefoilen", "Windfoilen"]
    
    var body: some View {
        VStack {
            NavigationLink(destination: AllSessionsView()) {
                Text("All Sessions")
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
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
        }
        .navigationTitle("Windcockpit")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            sessionManager.requestLocationManagerPermission()
            sessionManager.requestAuthorization()
        }
    }
}
