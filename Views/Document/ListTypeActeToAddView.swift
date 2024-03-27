//
//  ListTypeActeToAddView.swift
//  Bordero
//
//  Created by Grande Variable on 13/02/2024.
//

import SwiftUI

struct ListTypeActeToAddView: View {
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(
        format: "version <= %d",
        argumentArray: [FormTypeActeSheet.getVersion()]
    )) var typeActes: FetchedResults<TypeActe>
    
    @State private var activeSheet : ActiveSheet?
    
    var body: some View {
        List {
            ForEach(typeActes, id:\.id) { type in
                RowTypeActeView(activeSheet: $activeSheet, type: type)
            }
        }
        .navigationTitle("Type d'acte")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    // TODO
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    ListTypeActeToAddView()
}
