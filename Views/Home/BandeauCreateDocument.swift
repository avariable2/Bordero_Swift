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
            FormDocumentView()
        } label: {
            TitleWithIconColorComponentView(titre : "Créer un document") {
                Image(systemName: "doc.badge.plus")
                    .foregroundStyle(.blue, .primary)
            }
                .background(backgroundColor)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
        
//        .cornerRadius(10)
    }
    
    var backgroundColor : Color {
        colorScheme == .dark ? .black : .white
    }
}

#Preview {
    VStack {
        BandeauCreateDocument()
    }
    
}
