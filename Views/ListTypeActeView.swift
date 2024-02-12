//
//  TypeActeView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

struct ListTypeActeView: View {
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(sortDescriptors: []) var typeActes: FetchedResults<TypeActe>
    
    @State private var showingAlert: Bool = false
    @State private var activeSheet : ActiveSheet?
    
    var body: some View {
        List {
            Section("Actions") {
                Button {
                    activeSheet = .createTypeActe
                } label: {
                    Label("Ajouter un type d'acte", systemImage: "plus")
                }
                
            }
            
            Section {
                ForEach(typeActes, id:\.id) { type in
                    
                    Button {
                        activeSheet = .editTypeActe(type: type)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(type.name ?? "Inconnu")
                                .font(.body)
                                .tint(.black)
                            
                            Text(String(format: "Prix : %.2f €", type.price))
                                .font(.caption)
                                .tint(.secondary)
                        }
                    }
                
                }
                
                
            } header: {
                Text("Votre liste")
            } footer: {
                Text("Swipe à droite ou à gauche pour voir les actions disponibles.")
            }
            
            
        }
        .navigationTitle("Type d'actes")
        .toolbar {
            EditButton()
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .createTypeActe:
                FormTypeActeView(activeSheet: $activeSheet)
                    .presentationDetents([.medium])
            case .editTypeActe(let type):
                FormTypeActeView(typeActe: type, activeSheet: $activeSheet)
                    .presentationDetents([.medium])
            default :
                EmptyView() // IMPOSSIBLE
            }
        }
        
    }
    
    func delete(at offsets: IndexSet) {
        
        for index in offsets {
            let typeActe = typeActes[index]
            moc.delete(typeActe)
        }
        
        do {
            try moc.save()
            print("Success")
        } catch let err {
            print(err.localizedDescription)
        }
    }
}

#Preview {
    ListTypeActeView()
}
