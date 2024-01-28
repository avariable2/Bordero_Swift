//
//  CardHomeView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

struct CardHomeView: View {
    
    let titre : String
    let couleur : Color
    
    var body: some View {
        VStack {
            Text(titre)
                .font(.title2)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(couleur)
        .cornerRadius(25)
    }
}

#Preview {
    CardHomeView(titre: "Salut", couleur: Color.red)
}
