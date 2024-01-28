//
//  TypeActeView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

struct TypeActeView: View {
    
    @State private var nom : String = ""
    
    var body: some View {
        VStack(spacing: 12) {
            
            Text("Ajouter un type d'acte")
                .font(.title)
            
            TextField("Nom", text: $nom)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button {
                
            } label: {
                Text("Ajouter")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
           
            Spacer()
        }

    }
}

#Preview {
    TypeActeView()
}
