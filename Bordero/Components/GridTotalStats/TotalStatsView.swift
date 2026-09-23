//
//  TotalStatsView.swift
//  Bordero
//
//  Created by Grande Variable on 18/09/2026.
//

import SwiftUI

struct TotalStatsView: View {
    @Environment(\.locale) private var locale

    var title: LocalizedStringKey
    var totalNumber: Int
    var amount: Double
    var progress: Double
    var color: Color = .purple

    private var currencyCode: String {
        locale.currency?.identifier ?? "EUR"
    }

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(totalNumber, format: .number)
                        .font(.headline)
                        .foregroundStyle(color)
                        .contentTransition(.numericText(value: Double(totalNumber)))
                        .animation(.snappy, value: totalNumber)
                }

                Text(amount, format: .currency(code: currencyCode))
                    .font(.title2)
                    .bold()
                    .contentTransition(.numericText(value: amount))
                    .animation(.snappy, value: amount)

                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(color)
                    .accessibilityLabel("Progression")
                    .accessibilityValue(
                        Text(
                            progress,
                            format: .percent.precision(.fractionLength(0))
                        ))
            }
            .frame(maxHeight: .infinity)
        }
        .clipShape(Rectangle())
    }
}

#Preview {
    TotalStatsView(title: "Total", totalNumber: 8, amount: 9450, progress: 0.4)
        .padding(.horizontal, 150)
        .background(.fill)

}
