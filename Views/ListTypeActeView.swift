//
//  TypeActeView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

enum ActiveSheet : Identifiable {
    case createTypeActe, editTypeActe(type : TypeActe)
    
    var id : Int {
        switch self {
        case.createTypeActe:
            return 0
            
        case .editTypeActe(type: let type):
            return type.hash
        }
    }
}

struct ListTypeActeView: View {
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(sortDescriptors: []) var typeActes: FetchedResults<TypeActe>
    
    @State private var showingAlert: Bool = false
    @State private var activeSheet : ActiveSheet?
    
    var body: some View {
        List {
            Section {
                Button {
                    activeSheet = .createTypeActe
                } label: {
                    Label("Ajouter un type d'acte", systemImage: "plus")
                }
                
            } header: {
                Text("Actions")
            }
            
            
            Section {
                ForEach(typeActes, id:\.self) { type in
                    
                    Button {
                        activeSheet = .editTypeActe(type: type)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(type.name ?? "Inconnu")
                                .font(.body)
                                .tint(.black)
                            
                            Text(String(format: "Prix : %.2f €", type.price))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                
                }
                .onDelete(perform: delete)
                
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
