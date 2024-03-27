//
//  GroupBoxStyle.swift
//  Bordero
//
//  Created by Grande Variable on 27/03/2024.
//

import SwiftUI

struct CustomGroupBoxStyle : GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            Divider()
            configuration.content
        }
        .padding()
        .background(Color.white.opacity(1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

//#Preview {
//    GroupBoxStyle()
//}
