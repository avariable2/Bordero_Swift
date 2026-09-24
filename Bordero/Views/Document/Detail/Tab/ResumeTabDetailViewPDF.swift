//
//  ResumeTabDetailViewPDF.swift
//  Bordero
//
//  Created by Grande Variable on 13/04/2024.
//

import SwiftUI

struct ResumeTabDetailViewPDF: View {
    @ObservedObject var document: Document

    var body: some View {
        Form {
            if document.estDeTypeFacture && document.status != .created {
                Section {
                    Label("Facture émise", systemImage: "lock.doc")
                        .font(.headline)
                    Text("Cette facture ne peut plus être modifiée ni supprimée dans Bordero.")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                if let client = document.client_ {
                    ClientRowView(firstname: client.firstname, name: client.lastname)
                } else {
                    Label {
                        Text("Le client n'a pas été retrouvé ou bien a été supprimé.")
                            .fontWeight(.regular)
                    } icon: {
                        Image(systemName: "person.crop.circle.badge.questionmark.fill")
                            .foregroundStyle(.yellow, .gray)
                            .imageScale(.large)
                    }
                }
            } header: {
                Text("Créer pour")
            }

            Section {
                HStack {
                    Text("Statut")
                    Spacer()
                    HStack(spacing: nil) {
                        Image(systemName: "circle.circle.fill")
                            .foregroundStyle(.black, document.determineColor())
                        Text(document.determineStatut())
                            .foregroundStyle(.primary)
                            .fontWeight(.light)
                    }
                }

                HStack {
                    Text("Reste à payer")
                    Spacer()
                    Text(document.resteAPayer, format: .currency(code: "EUR"))
                        .fontWeight(.semibold)
                }

                LabeledContent("Date d'émission") {
                    Text(document.dateEmission.formatted(.dateTime.day().month().year()))
                        .foregroundStyle(.primary)
                        .fontWeight(.light)
                }

                LabeledContent("Date d'échéance") {
                    Text(document.dateEcheance.formatted(.dateTime.day().month().year()))
                        .foregroundStyle(.primary)
                        .fontWeight(.light)
                }
            } header: {
                Text("Informations")
            }

            Section {
                DocumentAmountRow(text: "Total H.T.", price: document.totalHT)
                DocumentAmountRow(text: "TVA", price: document.totalTVA)
                DocumentAmountRow(text: "Total T.T.C.", price: document.totalTTC)
            } header: {
                Text("Détails")
            }
        }
    }
}

private struct DocumentAmountRow: View {
    var text: String
    var price: Double
    
    var body: some View {
        HStack {
            Text(text.uppercased())
                .foregroundStyle(.secondary)
                .font(.caption)
            
            Spacer()
            
            Text(price, format: .currency(code: "EUR"))
                .fontWeight(.light)
        }
    }
}

#Preview {
    ResumeTabDetailViewPDF(document: Document.example)
}
