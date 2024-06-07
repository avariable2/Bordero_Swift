//
//  DisplayPayementSheet.swift
//  Bordero
//
//  Created by Grande Variable on 07/06/2024.
//

import Foundation
import SwiftUI

struct DisplayPayementSheet : View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.dismiss) var dismiss
    
    let paiement: Paiement
    private var nomClient = ""
    
    init(paiement: Paiement) {
        self.paiement = paiement
        if let client = paiement.client {
            nomClient = "\(client.firstname) \(client.lastname)"
        }
    }
    
    var body: some View {
        VStack {
            List {
                LabeledContent("Montant") {
                    Text(paiement.montant, format: .currency(code: "EUR"))
                }
                
                LabeledContent("Payée le ") {
                    if let date = paiement.date_ {
                        Text(date, format: .dateTime.day().month().year())
                    } else {
                        Text("Date inconnue")
                    }
                }
                
                LabeledContent("Notes") {
                    Text(paiement.note ?? "")
                }
            }
            .navigationTitle(nomClient.isEmpty ? "Paiement" : "Paiement de \(nomClient)")
            .navigationBarItems(trailing: toolbarButton)
            .safeAreaInset(edge: .bottom) {
                if horizontalSizeClass == .compact {
                    safeAreaButton
                }
            }
        }
        
    }
    
    var toolbarButton : some View {
        Group {
            if horizontalSizeClass == .regular {
                Button(role: .destructive) {
                    delete()
                } label: {
                    Label("Supprimer", systemImage: "trash")
                }
            }
        }
    }
    
    var safeAreaButton : some View {
        Button(role: .destructive) {
            delete()
        } label: {
            Label("Supprimer", systemImage: "trash")
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .background(Color.red)
    }
    
    func delete() {
        if let doc = paiement.document {
            if doc.resteAPayer + paiement.montant >= 0 { // ex : reste = -100 alors on veut verifier que le reste est supperieur à 0 pour changer l'etat
                doc.status = .send
            } else {
                doc.status = .payed
            }
        }
        
        dismiss()
        moc.delete(paiement)
        try? moc.save()
    }
}

#Preview {
    NavigationStack {
        DisplayPayementSheet(paiement: Paiement.example)
    }
}
