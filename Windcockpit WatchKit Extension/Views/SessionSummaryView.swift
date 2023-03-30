//
//  SessionSummaryView.swift
//  Windcockpit WatchKit App
//
//  Created by Ralf Wirdemann on 30.03.23.
//

import SwiftUI

struct SessionSummaryView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                Text("Session Summary")
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

struct SessionSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SessionSummaryView()
    }
}
