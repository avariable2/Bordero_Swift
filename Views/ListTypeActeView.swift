//
//  TypeActeView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

struct ListTypeActeView: View {
    @FetchRequest(sortDescriptors: []) var typeActes: FetchedResults<TypeActe>
    var body: some View {
        VStack {
            List(typeActes) { type in
                Text(type.name ?? "Inconnu")
            }
            .navigationTitle("Liste de tous les types d'actes")
        }
    }
}

#Preview {
    ListTypeActeView()
}
