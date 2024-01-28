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
        NavigationStack {
            List {
                ForEach(typeActes, id:\.self) { type in
                    Text(type.name ?? "Inconnu")
                }
                .onDelete(perform: delete)
                
            }
            .navigationTitle("Liste de tous les types d'actes")
            .toolbar {
                EditButton()
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
//        typeActes.nsSortDescriptors.remove(at: offsets.)
    }
}

#Preview {
    ListTypeActeView()
}
