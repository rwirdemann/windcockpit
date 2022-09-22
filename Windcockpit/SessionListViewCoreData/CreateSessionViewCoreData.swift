//
//  SessionView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 22.05.22.
//

import SwiftUI
import CoreData

struct CreateSessionViewCoreData: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var spotListModel: SpotListModel
    @State private var selectedSpot: LocationEntity?
    @State private var sport = "Wingfoiling"
    @State private var date = Date()
    @State private var showingAlert = false
    @State private var errorMessage = ""
    
    let sports = ["Wingfoiling", "Windsurfing", "Kitesurfing"]

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LocationEntity.name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<LocationEntity>

    fileprivate func saveSession() {
        let newItem = SessionEntity(context: viewContext)
        newItem.date = date
        newItem.location = selectedSpot?.name ?? "unknown"
        newItem.name = sport
        newItem.published = false
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        Form {
            HStack {
                Text("Spot")
                Spacer()
                Picker("", selection: $selectedSpot) {
                    ForEach(items) { location in
                        Text(location.name!)
                            .tag(Optional(location))
                    }
                }.pickerStyle(MenuPickerStyle())
            }

            HStack {
                Text("Wann")
                Spacer()
                DatePicker("", selection: $date, displayedComponents: .date)
                    .environment(\.locale, Locale.init(identifier: "de_DE"))
            }

            HStack {
                Text("Aktivität")
                Spacer()
                Picker("", selection: $sport) {
                    ForEach(sports, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
        .alert(errorMessage, isPresented: $showingAlert)  {
            Button("OK", role: .cancel) {}
        }
        .navigationTitle("Neue Session")
        .toolbar{
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Save", action : saveSession)
                    .disabled(self.selectedSpot == nil)
            }
        }
    }
}
