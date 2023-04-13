//
//  SessionCell.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 18.08.22.
//

import SwiftUI

struct SessionCell: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var session: SessionEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(session.spot?.name ?? "")
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            let sport = session.name ?? ""
            let published = session.extid != 0 ? "published" : "local"
            Text("\(sport) (\(published))")
                .font(.footnote)
                .foregroundColor(.blue)
            
            Text(toString(from: session.date ?? Date()))
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}
