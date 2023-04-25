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
    
    var body: some View {
        List {
            NavigationLink {
                AllSessionsView()
            } label: {
                Label("All Sessions...", systemImage: "figure.surfing")
            }.padding(
                EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5)
            )
            
            ForEach(Constants.SPORTS, id: \.self) { sessionType in
                NavigationLink(
                    sessionType,
                    destination: SessionPagingView(),
                    tag: sessionType,
                    selection: $sessionManager.selectedSessionType
                ).padding(
                    EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5)
                )
            }            
        }
        .listStyle(.carousel)
        .navigationTitle("Windcockpit")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            sessionManager.requestLocationManagerPermission()
            sessionManager.requestAuthorization()
        }
    }
}
