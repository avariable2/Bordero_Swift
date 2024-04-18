//
//  GroupBoxStyle.swift
//  Bordero
//
//  Created by Grande Variable on 27/03/2024.
//

import SwiftUI

struct CustomGroupBoxStyle : GroupBoxStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            Divider()
            configuration.content
        }
        .padding()
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    var background : Color {
        colorScheme == .dark ? Color(uiColor: .secondarySystemBackground) : Color.white
    }
}

#Preview {
    VStack {
        GroupBox {
            Text("Salut")
        }
        .groupBoxStyle(CustomGroupBoxStyle())
    }
}
