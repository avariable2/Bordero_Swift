//
//  BandeauCreateDocument.swift
//  Bordero
//
//  Created by Grande Variable on 24/02/2024.
//

import SwiftUI

struct BandeauCreateDocument: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationLink {
            DocumentFormView()
        } label: {
            TitleWithIconColorComponentView(titre : "Créer un document") {
                Image(systemName: "doc.fill.badge.plus")
                    .foregroundStyle(.green, .gray)
            }
            .background(backgroundColor)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    var backgroundColor : Color {
        if colorScheme == .dark {
            Color(uiColor: .quaternarySystemFill)
        } else {
            .white
        }
    }
}

#Preview {
    NavigationStack {
        BandeauCreateDocument()
    }
    
}
