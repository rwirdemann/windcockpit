//
//  SessionCell.swift
//  Windcockpit
//
//  Created by Ralf Wirdemann on 22.05.22.
//

import SwiftUI

struct SessionCell: View {
    @Environment(\.colorScheme) var colorScheme
    
    let session: Session
    
    var body: some View {
        HStack {
            Image(colorScheme == .light ? "wingfoiling-light" : "wingfoiling-dark")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .padding(.leading, -10)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(session.location)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(session.name)
                    .font(.footnote)
                    .foregroundColor(.secondary)

                Text(toString(from: session.date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }

    func color() -> Color {
        if session.date > Date() {
            return .primary
        }
        return .secondary
    }
}
