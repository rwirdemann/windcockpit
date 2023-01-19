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
    
    var body: some View {
        Form {
            if let spot = Binding<LocationEntity>($session.spot) {
                Picker("Spot", selection: spot) {
                    ForEach(spots, id: \.self) { s in
                        Text(s.name!)
                    }
                }
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
