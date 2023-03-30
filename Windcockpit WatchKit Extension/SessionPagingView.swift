//
//  SessionPagingView.swift
//  WindcockpitWatch WatchKit Extension
//
//  Created by Ralf Wirdemann on 15.07.22.
//

import SwiftUI

struct SessionPagingView: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @State private var selection: Tab = .metrics
    @EnvironmentObject var sessionManager: SessionManager
    
    enum Tab {
        case controls, metrics
    }
    
    var body: some View {
        TabView(selection: $selection) {
            ControlsView().tag(Tab.controls)
            SessionView().tag(Tab.metrics)
        }
        .navigationTitle(sessionManager.selectedSessionType ?? "")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(false)
        .onChange(of: sessionManager.running) { _ in
            displayMetricsView()
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: isLuminanceReduced ? .never : .automatic))
        .onChange(of: isLuminanceReduced) { _ in
            displayMetricsView()
        }
    }
    
    private func displayMetricsView() {
        withAnimation {
            selection = .metrics
        }
    }
}
