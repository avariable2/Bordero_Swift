//
//  HistoriquePayementIntent.swift
//  Bordero
//
//  Created by Grande Variable on 08/07/2024.
//

import AppIntents
import SwiftUI

struct ConsultPayementsIntent : AppIntent {
    static let title: LocalizedStringResource = "Consulter Paiements"
    
    static let description = IntentDescription("Récupére et affiche la liste de paiements renseigner dans l'application.")
    
    @Parameter(title: "Date de début")
    var startDate : Date?
    
    func perform() async throws -> some IntentResult & ProvidesDialog { // ReturnsValue<String>
        let payments = fetchPayement(startDate: startDate)
        
        let formattedPayments = payments.map { paiement in
            "Payment ID: \(paiement.id?.uuidString ?? "N/A"), Amount: \(paiement.montant), Date: \(paiement.date.description)"
        }.joined(separator: "\n")
        
        return .result(dialog: IntentDialog(stringLiteral: formattedPayments))
    }
    
    private func fetchPayement(startDate: Date?) -> [Paiement] {
        let context = DataController.shared.container.viewContext
        let fetchRequest = Paiement.fetch()
        
        var predicate : [NSPredicate] = []
        
        if let startDate = startDate {
            predicate.append(NSPredicate(format: "date_ >= %@", startDate as NSDate))
        }
        
        if !predicate.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicate)
        }
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch paiements : \(error)")
            return []
        }
    }
}
