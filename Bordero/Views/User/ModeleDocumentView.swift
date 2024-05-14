//
//  ModeleDocumentView.swift
//  Bordero
//
//  Created by Grande Variable on 21/03/2024.
//

import SwiftUI

struct ModeleDocumentView: View {
    @Environment(\.dismiss) var dismiss
    @State var praticien : Praticien
    
    @State private var color: Color = .green
    
    var body: some View {
        VStack {
            Form {
                Section {
                    ColorPicker("Couleur des documents", selection: $color, supportsOpacity: false)
                        .foregroundStyle(.secondary)
                        .disabled(true)
                    
                    NavigationLink("Modèle de facture") {
                        EmptyView()
                    }
                    .disabled(true)
                } header: {
                    
                } footer: {
                    Text("🏗️ En construction. Disponible dans une future mise à jour.")
                }
                
                Section {
                    Toggle(isOn: $praticien.paramsDocument.showDateEcheance) {
                        Text("Afficher la date d'échéance")
                    }
                    
                    Toggle(isOn: $praticien.paramsDocument.showModePaiement) {
                        Text("Afficher les mode de paiement")
                    }
                }
            }
        }
        .navigationTitle("Conception du modèle")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    save()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
    
    func save() {
        DataController.saveContext()
    }
}

#Preview {
    ModeleDocumentView(praticien: Praticien.example)
}
