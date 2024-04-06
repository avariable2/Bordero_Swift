//
//  TypeActeView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

struct ListTypeActeView: View {
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(
        format: "version <= %d",
        argumentArray: [FormTypeActeSheet.getVersion()]
    )) 
    var typeActes: FetchedResults<TypeActe>
    
    @State private var showingAlert: Bool = false
    @State private var activeSheet : ActiveSheet?
    
    var body: some View {
        List {
            Section {
                ForEach(typeActes, id:\.id) { type in
                    RowTypeActeView(activeSheet: $activeSheet, type: type)
                }
                .onDelete(perform: delete)
                
            } footer: {
                Text("Swipe à droite ou à gauche pour voir les actions disponibles.")
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

struct RowTypeActeView : View, Saveable {
    
    @Environment(\.managedObjectContext) var moc
    @Binding var activeSheet : ActiveSheet?
    let type : TypeActe
    
    var body: some View {
        
        Button {
            activeSheet = .editTypeActe(type: type)
        } label: {
            HStack {
                Image(systemName: "cross.case.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(.white, .purple)
                
                VStack(alignment: .leading) {
                    Text(type.name ?? "Inconnu")
                        .font(.body)
                        .tint(.primary)
                    
                    Text(String(format: "Prix total : %.2f €", type.total))
                        .font(.caption)
                        .tint(.secondary)
                }
                
                Spacer()
                
//                Button {
//                    type.favoris.toggle()
//                    save()
//                } label: {
//                    Image(systemName: type.favoris ? "heart.fill" : "heart")
//                        .tint(.red)
//                }
//                .contentTransition(.symbolEffect(.replace.upUp.byLayer))
//                .symbolEffect(.replace.upUp.byLayer, value: type.favoris)
            }
        }
    }
    
    func save() {
        do {
            try moc.save()
            print("Success")
        } catch let err {
            print("error \(err)")
        }
    }
}

#Preview {
    ListTypeActeView()
}
