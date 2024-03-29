//
//  CreateSessionView.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 22.05.22.
//

import SwiftUI
import CoreData

struct CreateSessionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedSpot: LocationEntity?
    @State private var sport = "Wingfoiling"
    @State private var date = Date()
    @State private var showingAlert = false
    @State private var errorMessage = ""
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LocationEntity.name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<LocationEntity>
    
    fileprivate func saveSession() {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(urls[urls.count-1] as URL)
        
        let s = SessionEntity(context: viewContext)
        s.date = date
        s.name = sport
        s.spot = selectedSpot
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
                Text("When")
                Spacer()
                DatePicker("", selection: $date, displayedComponents: .date)
                    .environment(\.locale, Locale.init(identifier: "de_DE"))
            }

            HStack {
                Text("Sport")
                Spacer()
                Picker("", selection: $sport) {
                    ForEach(Constants.SPORTS, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
        .alert(errorMessage, isPresented: $showingAlert)  {
            Button("OK", role: .cancel) {}
        }
        .onAppear {
            if !self.items.isEmpty {
                self.selectedSpot = self.items.first
            }
        }
        .navigationTitle("New Session")
        .toolbar{
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Save", action : saveSession)
                    .disabled(self.selectedSpot == nil)
            }
        }
    }
}
