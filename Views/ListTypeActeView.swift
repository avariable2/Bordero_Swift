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
    
    var body: some View {
        List {
            Section {
                Button {
                    showingAlert = true
                } label: {
                    Label("Ajouter un type d'acte", systemImage: "plus")
                        
                }.sheet(isPresented: $showingAlert) {
                    CreateTypeActeView(showingAlert: $showingAlert)
                        .presentationDetents([.medium])
                }
            } header: {
                Text("Actions")
            }
            
            
            Section {
                ForEach(typeActes, id:\.self) { type in
                    VStack(alignment: .leading) {
                        Text(type.name ?? "Inconnu")
                            .font(.body)
                        
                        Text(String(format: "Prix : %.2f €", type.price))
                            .font(.caption)
                            .foregroundStyle(.secondary)
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
