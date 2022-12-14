//
//  ControlsView.swift
//  WindcockpitWatch WatchKit Extension
//
//  Created by Ralf Wirdemann on 17.07.22.
//

import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
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
                        Image(systemName: "plus")
                    }
                    .tint(Color.green)
                    .font(.title2)
                    Text("New")
                }
            }
            HStack {
                VStack {
                    Button {
                        workoutManager.endWorkout()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(Color.red)
                    .font(.title2)
                    Text("End")
                }
                VStack {
                    Button {
                        workoutManager.togglePause()
                    } label: {
                        Image(systemName: workoutManager.running ? "pause" : "play")
                    }
                    .tint(Color.yellow)
                    .font(.title2)
                    Text(workoutManager.running ? "Pause" : "Resume")
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
