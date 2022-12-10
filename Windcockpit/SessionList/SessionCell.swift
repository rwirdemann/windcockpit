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
        HStack {
            ZStack {
                Circle()
                    .stroke(.blue, lineWidth: 1)
                Text(short(name: session.name ?? "Wingfoiling"))
                    .font(.system(size: 20))
            }
            .frame(width: 50, height: 50)
            .padding(.leading, -10)
            
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
            
            Spacer()
        }
    }
}
