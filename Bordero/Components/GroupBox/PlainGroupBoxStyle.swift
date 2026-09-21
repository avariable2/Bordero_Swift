//
//  PlainGroupBoxStyle.swift
//  Bordero
//
//  Created by Grande Variable on 21/09/2026.
//

import SwiftUI

struct PlainGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            configuration.label
            configuration.content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 20)
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
