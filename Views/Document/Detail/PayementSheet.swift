//
//  PayementSheet.swift
//  Bordero
//
//  Created by Grande Variable on 12/05/2024.
//

import SwiftUI

struct PayementSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var fullText: String = ""
    @State private var amount : Double = 0
    @State private var date : Date = Date()
    
    var body: some View {
        VStack {
            List {
                LabeledContent("Montant") {
                    
                    TextField("Montant", value: $amount, format: .currency(code: "EUR"), prompt: Text("0,00 €"))
                        .multilineTextAlignment(.trailing)
                }
                
                DatePicker("Payé le", selection: $date, displayedComponents: .date)
                
                Section("Notes - optionnel") {
                    TextEditor(text: $fullText)
                }
                
            }
            .listStyle(.grouped)
            .navigationTitle("Ajouter un paiement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Retour", role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        
                    } label: {
                        Text("Ajouter")
                    }

                }
            }
        }
    }
}

#Preview {
    PayementSheet()
}
