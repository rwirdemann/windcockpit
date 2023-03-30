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
                destination: Text(sessionType),
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

extension HKWorkoutActivityType: Identifiable {
    public var id: UInt {
        rawValue
    }
    
    var name: String {
        switch self {
        case .cycling:
            return "Wingfoiling"
        case .sailing:
            return "Windsurfing"
        case .surfingSports:
            return "Kitesurfing"
        default:
            return ""
        }
    }
}
