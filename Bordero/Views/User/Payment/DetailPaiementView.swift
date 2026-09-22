//
//  DetailPaiementView.swift
//  Bordero
//
//  Created by Grande Variable on 07/06/2024.
//

import CoreData
import SwiftUI

struct DetailPaiementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.locale) private var locale
    @Environment(\.managedObjectContext) private var managedObjectContext

    @State private var isConfirmingDeletion = false
    @State private var isShowingDeletionError = false

    var paiement: Paiement

    private var clientName: String {
        let components = [paiement.client?.firstname, paiement.client?.lastname]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        return components.joined(separator: " ")
    }

    private var currencyCode: String {
        locale.currency?.identifier ?? "EUR"
    }

    private var navigationTitle: String {
        clientName.isEmpty
            ? String(localized: "Paiement")
            : String(localized: "Paiement de \(clientName)")
    }

    var body: some View {
        List {
            Section("Informations") {
                LabeledContent("Montant") {
                    Text(paiement.montant, format: .currency(code: currencyCode))
                        .fontWeight(.semibold)
                }

                LabeledContent("Payé le") {
                    if let date = paiement.date_ {
                        Text(date, format: .dateTime.day().month().year())
                    } else {
                        Text("Date inconnue")
                            .foregroundStyle(.secondary)
                    }
                }

                LabeledContent("Facture") {
                    Text("#\(paiement.document?.numero ?? String(localized: "Inconnue"))")
                        .monospacedDigit()
                }
            }

            Section("Notes") {
                Text(paiement.note?.isEmpty == false ? paiement.note ?? "" : "Aucune note")
                    .foregroundStyle(paiement.note?.isEmpty == false ? .primary : .secondary)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if horizontalSizeClass == .regular {
                ToolbarItem(placement: .destructiveAction) {
                    deleteButton
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if horizontalSizeClass == .compact {
                compactDeleteButton
            }
        }
        .confirmationDialog(
            "Supprimer ce paiement ?",
            isPresented: $isConfirmingDeletion,
            titleVisibility: .visible
        ) {
            Button("Supprimer", role: .destructive, action: delete)
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Cette action mettra également à jour le statut de la facture associée.")
        }
        .alert(
            "Suppression impossible",
            isPresented: $isShowingDeletionError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Le paiement n’a pas pu être supprimé. Réessayez dans quelques instants.")
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            isConfirmingDeletion = true
        } label: {
            Label("Supprimer", systemImage: "trash")
        }
    }

    private var compactDeleteButton: some View {
        Button(role: .destructive) {
            isConfirmingDeletion = true
        } label: {
            Label("Supprimer le paiement", systemImage: "trash")
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.red, in: .rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .padding()
        .background(.bar)
    }

    private func delete() {
        if let document = paiement.document,
            document.paiements?.count == 1
        {
            document.status = .send
        }

        managedObjectContext.delete(paiement)

        do {
            try managedObjectContext.save()
            dismiss()
        } catch {
            managedObjectContext.rollback()
            isShowingDeletionError = true
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        DetailPaiementView(paiement: Paiement.example)
    }
}
#endif
