import SwiftUI

struct TendancesVisualTheme {
    var palette: TendancesThemePalette

    static var facturierOriginal: Self {
        Self(
            palette: TendancesThemePalette(
                accent: .green,
                canvasTint: .green.opacity(0.018),
                border: .green.opacity(0.55),
                primaryMetric: .green,
                collected: .teal,
                due: .brown,
                overdue: .red,
                gridLine: .green.opacity(0.12),
                borderWidth: 1,
                shadowColor: .clear,
                shadowRadius: 0,
                gridSpacing: 26,
                showsVerticalGrid: true
            )
        )
    }
}

extension EnvironmentValues {
    @Entry var tendancesVisualTheme: TendancesVisualTheme?
}
