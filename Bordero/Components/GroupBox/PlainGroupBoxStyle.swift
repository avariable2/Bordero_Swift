//
//  PlainGroupBoxStyle.swift
//  Bordero
//
//  Created by Grande Variable on 21/09/2026.
//

import SwiftUI

struct PlainGroupBoxStyle: GroupBoxStyle {
    @Environment(\.homeVisualTheme) private var theme

    func makeBody(configuration: Configuration) -> some View {
        let palette = theme?.palette
        let shape = Rectangle()

        VStack(alignment: .leading, spacing: 10) {
            configuration.label
                .font(.title3)
                .bold()
            configuration.content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            shape.fill(Color(.secondarySystemGroupedBackground))
        }
        .overlay {
            shape.stroke(
                palette?.border ?? Color.clear,
                lineWidth: palette?.borderWidth ?? 0
            )
        }
        .shadow(
            color: palette?.shadowColor ?? Color.clear,
            radius: palette?.shadowRadius ?? 0,
            y: (palette?.shadowRadius ?? 0) / 2
        )
    }
}

#Preview {
    GroupBox {
        Text("Contenu")
    } label: {
        Text("Titre")
            .font(.title2)
    }
    .groupBoxStyle(PlainGroupBoxStyle())
    .padding()
}
