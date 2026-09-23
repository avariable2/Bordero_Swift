import SwiftUI

struct HomePaperBackgroundView: View {
    var theme: HomeVisualTheme
    var verticalOffset: CGFloat = 0

    var body: some View {
        let palette = theme.palette

        ZStack {
            Rectangle().fill(.background)
            palette.canvasTint

            Canvas { context, size in
                let spacing = palette.gridSpacing
                let scrollPhase = -verticalOffset.truncatingRemainder(
                    dividingBy: spacing
                )
                var horizontalLines = Path()
                for y in stride(
                    from: scrollPhase - spacing,
                    through: size.height + spacing,
                    by: spacing
                ) {
                    horizontalLines.move(to: CGPoint(x: 0, y: y))
                    horizontalLines.addLine(to: CGPoint(x: size.width, y: y))
                }
                context.stroke(
                    horizontalLines,
                    with: .color(palette.gridLine),
                    lineWidth: 0.5
                )

                if palette.showsVerticalGrid {
                    var verticalLines = Path()
                    for x in stride(
                        from: spacing,
                        through: size.width,
                        by: spacing
                    ) {
                        verticalLines.move(to: CGPoint(x: x, y: 0))
                        verticalLines.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    context.stroke(
                        verticalLines,
                        with: .color(palette.gridLine),
                        lineWidth: 0.5
                    )
                }
            }
        }
        .accessibilityHidden(true)
    }
}
