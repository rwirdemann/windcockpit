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
            if let spot = Binding<LocationEntity>($session.spot) {
                Picker("Spot", selection: spot) {
                    ForEach(spots, id: \.self) { s in
                        Text(s.name!)
                    }
                }
            }
            if let distance = Binding<Double?>($session.distance) {
                TextField("Distance", value: distance, formatter: formatter)
            }
            let distance = Measurement(value: session.distance, unit: UnitLength.meters )
                .formatted( .measurement(width: .abbreviated, usage: .road)
                )
            Text(distance)

            HStack {
                if let duration = Binding<Double?>($session.duration) {
                    TextField("Duration", value: duration, formatter: formatter)
                }
                DurationView(duration: session.duration)
            }
        }
        .navigationTitle("Your Session")
        .toolbar{
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Save") {
                    
                    try? context.save()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
