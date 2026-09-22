//
//  ListHistoriquesPaiements.swift
//  Bordero
//
//  Created by Grande Variable on 17/05/2024.
//

import CoreData
import SwiftUI

struct ListHistoriquesPaiements: View {
    private static let maximumDisplayedPayments = 8

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Paiement.date_, ascending: false)
        ]
    )
    private var payments: FetchedResults<Paiement>

    private var recentPayments: [Paiement] {
        Array(payments.prefix(Self.maximumDisplayedPayments))
    }

    var body: some View {
        Group {
            if payments.isEmpty {
                ContentUnavailableView(
                    "Pas de paiement",
                    systemImage: "creditcard",
                    description: Text("Les paiements de vos clients apparaîtront ici.")
                )
                .frame(minHeight: 120)
            } else {
                VStack(spacing: 0) {
                    ForEach(recentPayments) { payment in
                        NavigationLink {
                            DetailPaiementView(paiement: payment)
                        } label: {
                            PaiementRowView(payment: payment)
                        }
                        .buttonStyle(.plain)

                        if payment.objectID != recentPayments.last?.objectID {
                            Divider()
                        }
                    }

                    if payments.count > Self.maximumDisplayedPayments {
                        Divider()
                            .padding(.top, 8)

                        NavigationLink {
                            ListAllClientPaiements()
                        } label: {
                            HStack(spacing: 10) {
                                Label("Voir tous les paiements", systemImage: "list.bullet")
                                    .fontWeight(.semibold)

                                Spacer()

                                Text(payments.count, format: .number)
                                    .foregroundStyle(.secondary)

                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .accessibilityHidden(true)
                            }
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(.tint.opacity(0.1), in: .rect(cornerRadius: 12))
                            .contentShape(.rect(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.tint)
                        .padding(.top, 12)
                        .accessibilityHint("Affiche l’historique complet")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background()
    }
}

#if DEBUG
#Preview("Paiements fictifs") {
    NavigationStack {
        List {
            ListHistoriquesPaiements()
        }
    }
    .environment(\.managedObjectContext, PreviewDataController.invoices.context)
}

#Preview("Sans données") {
    NavigationStack {
        List {
            ListHistoriquesPaiements()
        }
    }
    .environment(\.managedObjectContext, PreviewDataController.empty.context)
}
#endif
