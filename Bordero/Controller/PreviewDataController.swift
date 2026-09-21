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

        let clients = seedClients()
        seedInvoices(for: clients)

        if !withInvoices {
            // Instancie les classes Core Data avant le premier @FetchRequest, puis
            // retire les objets afin de conserver un contexte de preview vide.
            context.rollback()
        }
    }

    private func seedClients() -> [Client] {
        let clientsData = [
            ("Camille", "Martin", "06 12 34 56 78", "camille.martin@example.com"),
            ("Louis", "Bernard", "06 23 45 67 89", "louis.bernard@example.com"),
            ("Inès", "Robert", "06 34 56 78 90", "ines.robert@example.com"),
            ("Hugo", "Petit", "06 45 67 89 01", "hugo.petit@example.com"),
            ("Léa", "Durand", "06 56 78 90 12", "lea.durand@example.com")
        ]

        return clientsData.map { firstname, lastname, phone, email in
            Client(
                firstname: firstname,
                lastname: lastname,
                phone: phone,
                email: email,
                context: context
            )
        }
    }

    private func seedInvoices(for clients: [Client]) {
        let calendar = Calendar.current
        let now = Date.now

        // Quatre mois de factures avec les trois statuts de paiement.
        for monthOffset in 0..<4 {
            let emissionDate = calendar.date(byAdding: .month, value: -monthOffset, to: now) ?? now
            for index in 0..<(12 + monthOffset * 3) {
                let document = Document(context: context)
                let amount = Double(80 + (index % 8) * 35)

                document.estDeTypeFacture = true
                document.dateEmission = emissionDate
                document.status = index % 3 == 0 ? .payed : .send
                document.numero = "FAC-\(2026 - monthOffset)-\(index + 1)"
                document.totalHT = amount
                document.totalTVA = amount * 0.2
                document.totalTTC = amount * 1.2
                document.client_ = clients[(index + monthOffset) % clients.count]
                document.dateEcheance = calendar.date(
                    byAdding: .day,
                    value: index % 3 == 2 ? -15 : 30,
                    to: now
                ) ?? now

                seedPayments(for: document, index: index, calendar: calendar)
            }
        }
        context.processPendingChanges()
    }

    private func seedPayments(for document: Document, index: Int, calendar: Calendar) {
        guard document.status == .payed || index % 4 == 0 else { return }

        let paymentCount = index % 5 == 0 ? 2 : 1
        let paidAmount = document.status == .payed ? document.totalTTC : document.totalTTC * 0.4

        for paymentIndex in 0..<paymentCount {
            let paymentDate = calendar.date(
                byAdding: .day,
                value: 5 + paymentIndex * 7,
                to: document.dateEmission
            ) ?? document.dateEmission
            let payment = Paiement(
                montant: paidAmount / Double(paymentCount),
                date: paymentDate,
                context: context
            )

            payment.document = document
            payment.client = document.client_
        }
    }
}
#endif
