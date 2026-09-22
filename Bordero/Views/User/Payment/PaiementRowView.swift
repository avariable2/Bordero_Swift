import SwiftUI

struct PaiementRowView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.locale) private var locale

    var payment: Paiement

    private var clientName: String {
        let components = [payment.client?.firstname, payment.client?.lastname]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        return components.isEmpty
            ? String(localized: "Client inconnu")
            : components.joined(separator: " ")
    }

    private var documentNumber: String {
        guard let number = payment.document?.numero, !number.isEmpty else {
            return String(localized: "Inconnu")
        }
        return number
    }

    private var currencyCode: String {
        locale.currency?.identifier ?? "EUR"
    }

    private var isPaidInFull: Bool {
        (payment.document?.resteAPayer ?? 0) <= 0
    }

    private var statusColor: Color {
        isPaidInFull ? .green : .orange
    }

    private var statusTitle: String {
        isPaidInFull ? DocumentStatus.paye.rawValue : DocumentStatus.envoyer.rawValue
    }

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) {
                    clientAndDate
                    amountAndStatus
                }
            } else {
                HStack(alignment: .center, spacing: 12) {
                    clientAndDate
                    Spacer(minLength: 12)
                    amountAndStatus
                }
            }
        }
        .padding(.vertical, 6)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }

    private var clientAndDate: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(clientName)
                .font(.body.weight(.medium))

            HStack(spacing: 6) {
                Text("#\(documentNumber)")
                    .monospacedDigit()

                Text("·")

                Text(payment.date, format: .dateTime.day().month(.abbreviated).year())
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private var amountAndStatus: some View {
        VStack(
            alignment: dynamicTypeSize.isAccessibilitySize ? .leading : .trailing,
            spacing: 5
        ) {
            Text(payment.montant, format: .currency(code: currencyCode))
                .font(.body.weight(.semibold))
                .monospacedDigit()

            Text(statusTitle)
                .font(.caption.weight(.medium))
                .foregroundStyle(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(statusColor.opacity(0.12), in: .capsule)
        }
    }
}

#if DEBUG
#Preview {
    PaiementRowView(payment: Paiement.example)
        .padding()
}
#endif
