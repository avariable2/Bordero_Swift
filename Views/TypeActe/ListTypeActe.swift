//
//  TypeActeView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

struct ListTypeActe: View {
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(
        format: "version <= %d",
        argumentArray: [FormTypeActeSheet.getVersion()]
    )) var typeActes: FetchedResults<TypeActe>
    @State private var searchText = ""
    
    @State private var showingAlert: Bool = false
    @State private var activeSheet : ActiveSheet?
    
    // MARK: - Uniquement pour la partie document
    var callbackClick : ((TypeActe) -> Void)?
    
    var filteredTypeActe : [TypeActe] {
        filteredTypeActe(typeActes: Array(typeActes), searchText: searchText)
    }
    
    var body: some View {
        VStack {
            if typeActes.isEmpty {
                ContentUnavailableView(label: {
                    Label("Aucun type d'acte", systemImage: "cross.case")
                }, description: {
                    Text("Les type d'acte ajoutés apparaîtront ici.")
                }, actions: {
                    Button {
                        activeSheet = .createTypeActe
                    } label: {
                        Text("Ajouter un type d'acte")
                    }
                })
            } else {
                List {
                    Section {
                        ForEach(filteredTypeActe, id: \.id) { type in
                            RowTypeActeView(activeSheet: $activeSheet, type: type, callback: callbackClick)
                        }
                        .onDelete(perform: delete)
                        
                    } footer: {
                        if !filteredTypeActe.isEmpty {
                            Text("Déplacé l'élément à gauche pour le supprimer.")
                        }
                    }
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Recherche"))
                .overlay(content: {
                    if filteredTypeActe.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    }
                })
                
            }
        }
        .navigationTitle("Type d'actes")
        .tint(.purple)

        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    activeSheet = .createTypeActe
                } label: {
                    Label("Ajouter un type d'acte", systemImage: "plus")
                }
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .createTypeActe:
                FormTypeActeSheet(onCancel: {
                    activeSheet = nil
                }, onSave: {
                    activeSheet = nil
                })
            case .editTypeActe(let type):
                FormTypeActeSheet(typeActeToModify: type, onCancel: {
                    activeSheet = nil
                }, onSave: {
                    activeSheet = nil
                })
            default :
                EmptyView() // IMPOSSIBLE
            }
        }
        
    }
    
    func filteredTypeActe(typeActes: [TypeActe], searchText: String) -> [TypeActe] {
        guard !searchText.isEmpty else { return typeActes }
        return typeActes.filter { type in
            type.name?.lowercased().contains(searchText.lowercased()) == true
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

struct RowTypeActeView : View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var activeSheet : ActiveSheet?
    let type : TypeActe
    let callback : ((TypeActe) -> Void)?
    
    var body: some View {
        if let call = callback {
            Button {
                call(type)
                dismiss()
            } label: {
                DisplayTypeActeView(text: type.name ?? "Inconnu", price: String(format: "Prix total : %.2f €", type.total))
            }
        } else {
            Button {
                activeSheet = .editTypeActe(type: type)
            } label: {
                DisplayTypeActeView(text: type.name ?? "Inconnu", price: String(format: "Prix total : %.2f €", type.total))
            }
        }
        
    }
}

struct DisplayTypeActeView : View {
    var text : String
    var price : String
    
    var body: some View {
        HStack {
            Image(systemName: "cross.case.circle.fill")
                .imageScale(.large)
                .foregroundStyle(.white, .purple)
            
            VStack(alignment: .leading) {
                Text(text)
                    .font(.body)
                    .tint(.primary)
                
                Text(price)
                    .font(.caption)
                    .tint(.secondary)
            }
        }
    }
}

#Preview {
    ListTypeActe()
}
