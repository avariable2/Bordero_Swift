//
//  BandeauCreateDocument.swift
//  Bordero
//
//  Created by Grande Variable on 24/02/2024.
//

import SwiftUI

struct BandeauCreateDocument: View {
    var body: some View {
        Button {
            
        } label: {
            HStack {
                Image(systemName: "stethoscope")
                    .foregroundStyle(.blue, .primary)
                    .font(.title2)
                Text("Créer mon premier document")
            }
            .font(.body)
            .tint(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.primary)
        .background(.regularMaterial)
        .cornerRadius(10)
        
    }
}

#Preview {
    BandeauCreateDocument()
}
