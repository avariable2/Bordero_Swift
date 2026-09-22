import SwiftUI
import Charts

struct DashboardChartAxesModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .chartXAxis {
                AxisMarks {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(anchor: .top)
                }
            }
            .chartYAxis {
                AxisMarks {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(anchor: .trailing)
                }
            }
    }
}

extension View {
    // Explicit anchors prevent an iOS 27 Charts layout failure during domain changes.
    func dashboardChartAxes() -> some View {
        modifier(DashboardChartAxesModifier())
    }
}
