//
//  ControlsView.swift
//  WindcockpitWatch WatchKit Extension
//
//  Created by Ralf Wirdemann on 17.07.22.
//

import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var sessionManager: SessionTracker
    
    var body: some View {
        
        
        VStack {
            HStack {
                VStack {
                    Button {
                        WKInterfaceDevice.current().enableWaterLock()
                    } label: {
                        Image(systemName: "drop.fill")
                    }
                    .tint(Color.cyan)
                    .font(.title2)
                    Text("Lock")
                }
                VStack {
                    Button {
                    } label: {
                        Image(systemName: "pause")
                    }
                    .tint(Color.yellow)
                    .font(.title2)
                    Text("Pause")
                }
            }
            HStack {
                VStack {
                    Button {
                        sessionManager.end()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(Color.red)
                    .font(.title2)
                    Text("End")
                }
                VStack {
                    Button {
                    } label: {
                        Image(systemName: "gear")
                    }
                    .tint(Color.gray)
                    .font(.title2)
                    Text("Settings")
                }
            }
        }
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView()
    }
}
