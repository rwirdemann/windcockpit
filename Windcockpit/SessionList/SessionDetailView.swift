//
//  SessionDetailView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 19.01.23.
//

import SwiftUI

struct SessionDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.editMode) private var editMode
    
    @ObservedObject var session: SessionEntity
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LocationEntity.name, ascending: true)],
        animation: .default)
    private var spots: FetchedResults<LocationEntity>
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        Form {
            let distance = Measurement(value: session.distance, unit: UnitLength.meters)
                .formatted(.measurement(width: .abbreviated, usage: .road))
            let maxSpeed = Measurement(value: session.maxspeed, unit: UnitSpeed.metersPerSecond)
                .formatted()
            
            if editMode?.wrappedValue.isEditing == true {
                if let spot = Binding<LocationEntity>($session.spot) {
                    Picker("Spot", selection: spot) {
                        ForEach(spots, id: \.self) { s in
                            Text(s.name!)
                        }
                    }
                }
                
                HStack {
                    Text("Distance")
                    Spacer()
                    TextField("",
                              value: $session.distance,
                              formatter: formatter)
                    .multilineTextAlignment(.trailing)
                    Text("m")
                }
                
                HStack {
                    Text("Maxspeed")
                    Spacer()
                    TextField("",
                              value: $session.maxspeed,
                              formatter: formatter)
                    .multilineTextAlignment(.trailing)
                    Text("km/h")
                }
            } else {
                DetailView(title: "Spot", value: session.spot?.name ?? "Unknwon")
                DetailView(title: "Sport", value: session.name)
                DetailView(title: "When", value: toString(from: session.date ?? Date()))
                DetailView(title: "Distance", value: distance)
                DetailView(title: "Max Speed", value: maxSpeed)
                HStack {
                    Text("Duration")
                    Spacer()
                    DurationView(duration: session.duration)
                }
            }
        }
        .navigationTitle("Your Session")
        .toolbar{
            EditButton()
        }
        .onChange(of: editMode!.wrappedValue, perform: { value in
            if !value.isEditing {
                session.maxspeed = session.maxspeed / 3.6
                try? context.save()
            } else {
                session.maxspeed = session.maxspeed * 3.6
            }
        })
    }
}

struct DetailView: View {
    var title: String
    var value: String?
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if value != nil {
                Text(value!)
            }
        }
    }
}
