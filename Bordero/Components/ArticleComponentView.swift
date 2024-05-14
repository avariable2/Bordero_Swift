//
//  ArticleComponentView.swift
//  Bordero
//
//  Created by Grande Variable on 24/02/2024.
//

import SwiftUI

struct ArticleComponentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var titre : String
    var sousTitre : String
    var image : String
    
    var body: some View {
        VStack {
            Image(image) // Remplacez par l'image appropriée
                .resizable()
                .frame(height: 120)
                .padding(.bottom, 10)
                .cornerRadius(10)
            
            VStack(alignment: .leading) {
                Text(titre)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(sousTitre)
                    .font(.body)
            }
            .foregroundColor(.primary)
            .padding()
            
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(backgroundColor)
        )
    }
    
    var backgroundColor : Color {
        if colorScheme == .dark {
            Color(UIColor.systemGray6)
        } else {
            .white
        }
    }
}

#Preview {
    ArticleComponentView(titre: "Suivi de vos traitements", sousTitre: "Découvrez en quoi il est important de suivre les traitements que vous prenez.", image: "ArticleImageFacture")
}
