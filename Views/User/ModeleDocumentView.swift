//
//  ModeleDocumentView.swift
//  Bordero
//
//  Created by Grande Variable on 21/03/2024.
//

import SwiftUI

struct ModeleDocumentView: View {
    @State private var color: Color = .green
    var body: some View {
        Form {
            Section("Conception du modèle") {
                ColorPicker("Couleur des documents", selection: $color)
                
                NavigationLink("Modèle de facture") {
                    EmptyView()
                }
                
                Toggle(isOn: .constant(true), label: {
                    Text("Afficher la date d'échéance")
                })
                
                Toggle(isOn: .constant(true), label: {
                    Text("Afficher les mode de paiement")
                })
                
                Toggle(isOn: .constant(true), label: {
                    Text("Afficher la date d'échéance")
                })
            }
        }
    }
}

#Preview {
    ModeleDocumentView()
}
