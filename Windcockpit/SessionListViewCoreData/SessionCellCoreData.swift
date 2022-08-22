//
//  SessionCellCoreData.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 18.08.22.
//

import SwiftUI

struct SessionCellCoreData: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var session: SessionEntity
    
    var body: some View {
        HStack {
            Image(colorScheme == .light ? "wingfoiling-light" : "wingfoiling-dark")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .padding(.leading, -10)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(session.location ?? "")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                let sport = session.name ?? ""
                let published = session.published ? "published" : "local"
                Text("\(sport) (\(published))")
                    .font(.footnote)
                    .foregroundColor(.blue)

                Text(toString(from: session.date ?? Date()))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}
