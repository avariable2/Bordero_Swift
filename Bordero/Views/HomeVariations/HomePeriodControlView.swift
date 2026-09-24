import SwiftUI

struct HomePeriodControlView: View {
    @Environment(\.tendancesVisualTheme) private var theme

    @Binding var selectedPeriod: StatisticsPeriod

    private var periodDescription: String {
        let calendar = Calendar.current
        let interval = selectedPeriod.interval(containing: .now, calendar: calendar)
        let finalDate = interval.end.addingTimeInterval(-1)
        return (interval.start..<finalDate).formatted(
            date: .abbreviated,
            time: .omitted
        )
    }

    var body: some View {
        let resolvedTheme = theme ?? .facturierOriginal
        let palette = resolvedTheme.palette
        let shape = Rectangle()

        VStack(alignment: .leading, spacing: 14) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline) {
                    Label(selectedPeriod.displayName, systemImage: "calendar")
                        .font(.headline)
                        .foregroundStyle(palette.accent)

                    Spacer(minLength: 16)

                    Text(periodDescription)
                        .font(.title3)
                        .bold()
                        .multilineTextAlignment(.trailing)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Label(selectedPeriod.displayName, systemImage: "calendar")
                        .font(.headline)
                        .foregroundStyle(palette.accent)

                    Text(periodDescription)
                        .font(.title3)
                        .bold()
                }
            }

            Picker("Période des statistiques", selection: $selectedPeriod) {
                ForEach(StatisticsPeriod.allCases) { period in
                    Text(period.displayName)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(16)
        .background {
            shape.fill(Color(.secondarySystemGroupedBackground))
        }
        .overlay {
            shape.stroke(palette.border, lineWidth: palette.borderWidth)
        }
        .shadow(
            color: palette.shadowColor,
            radius: palette.shadowRadius,
            y: palette.shadowRadius / 2
        )
    }
}
