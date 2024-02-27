//
//  CreateTypeActeView.swift
//  Bordero
//
//  Created by Grande Variable on 05/02/2024.
//

import SwiftUI

struct FormTypeActeView: View, Saveable, Modifyable, Versionnable {
    func getVersion() -> Int32 {
        return 1
    }
    
    @Environment(\.managedObjectContext) var moc
    
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    @State var typeActeToModify : TypeActe?
    
    @Binding var activeSheet: ActiveSheet?
    
    @State private var nom : String = ""
    @State private var numberString: String = ""
    @State private var floatValue: Float?
    
    private var disableForm: Bool {
        nom.isEmpty || floatValue == nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("* Entrer un nom", text: $nom)
                        .keyboardType(.default)
                        
                    TextField("* Entrer un prix", text: $numberString)
                        .keyboardType(.decimalPad)
                        .onChange(of: numberString) {
                            validateNumberString()
                        }
                } header: {
                    Text("Champs à saisir")
                } footer: {
                    Text("* Tous les champs sont obligatoires.")
                }
            }
            .navigationTitle(typeActeToModify == nil ? "Créer un type d'acte" : "Type d'acte")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler", role: .destructive) {
                        numberString = ""
                        floatValue = nil
                        nom = ""
                        
                        activeSheet = nil
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("OK") {
                        modify()
                        
                        activeSheet = nil
                    }
                    .disabled(disableForm)
                }
            }
        }
        .onAppear {
            if let typeActe = typeActeToModify {
                nom = typeActe.name ?? ""
                numberString = String(format: "%.2f", typeActe.price)
                floatValue = typeActe.price
            }
        }
    }
    
    private func validateNumberString() {
        floatValue = Float(numberString.replacingOccurrences(of: ",", with: ".")) ?? nil
    }
    
    func modify() {
        guard let prix = floatValue else {
            print("Il y'a une erreur avec la valeur set dans la modal")
            return
        }
        
        let typeActe = typeActeToModify ?? TypeActe(context: moc)
        typeActe.version = getVersion()
        
        typeActe.name = nom
        typeActe.price = prix
        
        save()
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
    FormTypeActeView(activeSheet: .constant(nil))
}
