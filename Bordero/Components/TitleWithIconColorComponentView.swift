//
//  TitleWithIconColorComponentView.swift
//  Bordero
//
//  Created by Grande Variable on 24/02/2024.
//

import SwiftUI

struct TitleWithIconColorComponentView<Content : View>: View {
    
    var title : String
    
    // Just pass the image and the color
    @ViewBuilder var image : Content
    
    var body: some View {
        HStack {
            image
                .imageScale(.large)
            
            Text(title)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary) // Couleur de la flèche
                .imageScale(.small)
        }
        .padding()
        .font(.body)
        .foregroundColor(.primary)
    }
}

#Preview {
    TitleWithIconColorComponentView(title: "Créer un document") {
        Image(systemName: "doc.badge.plus")
            .foregroundStyle(.blue, .primary)
    }
    .padding()
}
