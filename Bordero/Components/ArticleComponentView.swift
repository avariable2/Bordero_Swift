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
            Image(image)
                .resizable()
                .frame(height: 180)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(titre)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(sousTitre)
                    .font(.headline)
                    .fontWeight(.regular)
            }
            .frame(minHeight: 140, alignment: .top)
            .foregroundColor(.primary)
            .padding([.leading, .trailing, .bottom])
            
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
    ZStack {
        Color.gray
        
        HStack(spacing: 30) {
            ArticleComponentView(titre: "Suivi de vos traitements", sousTitre: "Découvrez en quoi il est important de suivre les traitements que vous prenez.", image: "ArticleImageFacture")
            
            ArticleComponentView(titre: "Pourquoi la santé\nauditive est-elle importante?", sousTitre: "Obtenez des statistiques sur votre audition et découvrez comment la préserver.", image: "ArticleImageFacture")
            
            ArticleComponentView(titre: "Ce que signifie un niveau de santé cardoiovasculaire faible", sousTitre: "Et ce que vous pouvez faire pour l'améliorer.", image: "ArticleImageFacture")
        }
        
    }
    
}
