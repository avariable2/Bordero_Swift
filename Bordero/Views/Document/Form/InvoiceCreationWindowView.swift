import SwiftUI

struct InvoiceCreationWindowView: View {
    @Environment(\.dismissWindow) private var dismissWindow

    var invoiceID: UUID?

    var body: some View {
        NavigationStack {
            DocumentFormView(onCancel: {
                if let invoiceID {
                    dismissWindow(id: "invoice-creation", value: invoiceID)
                }
            })
        }
    }
}
