import CoreData
import Foundation

#if DEBUG
@MainActor
final class PreviewDataController {
    static let invoices = PreviewDataController(withInvoices: true)
    static let empty = PreviewDataController(withInvoices: false)

    private let container: NSPersistentContainer

    var context: NSManagedObjectContext {
        container.viewContext
    }

    private init(withInvoices: Bool) {
        container = NSPersistentContainer(name: "Model")
        let description = NSPersistentStoreDescription()
        // Stockage éphémère compatible avec le modèle, sans accès aux données de l'app.
        description.url = URL(fileURLWithPath: "/dev/null")
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Impossible de charger les données de preview : \(error)")
            }
        }

        if withInvoices {
            seedInvoices()
        }
    }

    private func seedInvoices() {
        let calendar = Calendar.current
        let now = Date()

        // Quatre mois de factures avec les trois statuts de paiement.
        for monthOffset in 0..<4 {
            let emissionDate = calendar.date(byAdding: .month, value: -monthOffset, to: now) ?? now
            for index in 0..<(12 + monthOffset * 3) {
                let document = Document(context: context)
                document.estDeTypeFacture = true
                document.dateEmission = emissionDate
                document.status = index % 3 == 0 ? .payed : .send
                document.dateEcheance = calendar.date(
                    byAdding: .day,
                    value: index % 3 == 2 ? -15 : 30,
                    to: now
                ) ?? now
            }
        }
        context.processPendingChanges()
    }
}
#endif
