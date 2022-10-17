//
//  CreateLocationViewCoreData.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 17.10.22.
//

import SwiftUI
import CoreData

struct CreateLocationViewCoreData: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @FocusState private var nameInFocus: Bool
    
    fileprivate func saveLoction() {
        let newItem = LocationEntity(context: viewContext)
        newItem.name = name
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
            TextField("Spotname", text: $name)
                .focused($nameInFocus)
        }
        .navigationTitle("Neuen Spot")
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.nameInFocus = true
          }
        }
        .toolbar{
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Save", action : saveLoction)
                    .disabled(self.name == "")
            }
        }
    }
}
