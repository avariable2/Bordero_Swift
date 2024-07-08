//
//  PayementSheet.swift
//  Bordero
//
//  Created by Grande Variable on 12/05/2024.
//

import SwiftUI

struct PayementSheet: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    let document : Document
    
    @State private var note: String = ""
    @State private var amount : Double = 0
    @State private var date : Date = Date()
    
    @State private var historiquePaiement : Array<Paiement> = []
    
    var body: some View {
        VStack {
            List {
                LabeledContent("Montant") {
                    
                    TextField("Montant", value: $amount, format: .currency(code: "EUR"), prompt: Text("0,00 €"))
                        .multilineTextAlignment(.trailing)
                }
                
                DatePicker("Payée le", selection: $date, displayedComponents: .date)
                
                Section("Notes - optionnelles") {
                    TextEditor(text: $note)
                }
                
                if !historiquePaiement.isEmpty {
                    Section {
                        ForEach(historiquePaiement) { paiement in
                            RowPaiementView(paiement: paiement)
                        }
                    } header : {
                        Text("Paiements reçus")
                            
                    }
                    .headerProminence(.increased)
                }
                
            }
            .listStyle(.grouped)
            .navigationTitle("Ajouter un paiement")
            .onAppear() {
                amount = document.resteAPayer
                historiquePaiement = Array(document.listPayements)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Retour", role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        addPayement()
                        dismiss()
                    } label: {
                        Text("Ajouter")
                    }
                    
                }
            }
        }
    }
    
    func addPayement() {
        let paiement = Paiement(context: moc)
        paiement.id = UUID()
        paiement.date = date
        paiement.montant = amount
        paiement.client = document.client_
        paiement.document = document
        
        if amount >= document.resteAPayer {
            document.status = .payed
        } else {
            document.status = .send
        }
        
        let historiquePaiement = HistoriqueEvenement(context: moc)
        historiquePaiement.id = UUID()
        historiquePaiement.nom = Evenement.TypeEvenement.payer.rawValue
        historiquePaiement.date = Date()
        historiquePaiement.correspond = document
        
        document.historique?.adding(historiquePaiement)
        
        removeNotification()
        
        AnalyticsService.shared.track(event: .paymentAdd, category: .paymentManagement, parameters: [
            "payment_id": paiement.id?.uuidString ?? "unknown",
            "amount": paiement.montant
        ])
        
        DataController.saveContext()
    }
    
    func removeNotification() {
        guard let documentID = document.id_?.uuidString else { return }
        
        // Supprimer les notifications en attente
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [documentID])
        
        // Supprimer les notifications livrées
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [documentID])
        
        print("Notification for document \(documentID) has been removed.")
    }
}

#Preview {
    NavigationStack {
        PayementSheet(document: Document.example)
    }
    
}

struct RowPaiementView : View {
    let paiement : Paiement
    
    var body: some View {
        NavigationLink {
            DisplayPayementSheet(paiement: paiement)
        } label: {
            HStack {
                Text(paiement.date_?.formatted() ?? "Date inconnue")
                Spacer()
                Text(paiement.montant, format: .currency(code: "EUR"))
            }
        }
    }
}
