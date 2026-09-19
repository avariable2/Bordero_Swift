import SwiftUI

struct FacturesStatutSelection: View {
    let period: String
    let data: [DocumentChartData]

    private var total: Int { data.reduce(0) { $0 + $1.count } }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(period).font(.caption)
            Text("Total : \(total)").font(.subheadline.bold())
            Text("Payé : \(count(for: .paye))").foregroundStyle(.green)
            Text("En attente : \(count(for: .envoyer))").foregroundStyle(.orange)
            Text("Impayé : \(count(for: .enRetard))").foregroundStyle(.red)
        }
        .font(.caption)
        .padding(8)
        .background(.secondary, in: .rect(cornerRadius: 8))
        .accessibilityElement(children: .combine)
    }

    private func count(for status: DocumentStatus) -> Int {
        data.first { $0.status == status }?.count ?? 0
    }
}
