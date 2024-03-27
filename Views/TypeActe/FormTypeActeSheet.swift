//
//  CreateTypeActeView.swift
//  Bordero
//
//  Created by Grande Variable on 05/02/2024.
//

import SwiftUI

struct FormTypeActeSheet: View, Saveable, Modifyable, Versionnable {
    static func getVersion() -> Int32 {
        return 1
    }
    
    @Environment(\.managedObjectContext) var moc
    
    @State var typeActeToModify : TypeActe?
    
    var onCancel: (() -> Void)?
    var onSave: (() -> Void)?
    
    @State private var nom : String = ""
    @State private var description : String = ""
    
    @State private var quantity = 1
    @State private var prix: Float = 0
    @State private var unit : String = ""
    
    @State private var applyTVA = false
    @State private var tva : Int = 20
    @State private var tot : Decimal = 0
    @State private var isDefault = false
    
    private var disableForm: Bool {
        nom.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Nom", text: $nom)
                        .keyboardType(.default)
                    
                    TextField("Description", text: $nom)
                        .keyboardType(.default)
                }
                
                Section {
                    LabeledContent("Quantité") {
                        TextField("1", value: $quantity, format: .number.precision(.fractionLength(0)))
                        
                    }
                    
                    LabeledContent("Prix") {
                        TextField("facultatif", value: $prix, format: .number.precision(.fractionLength(2)))
                        
                    }
                    
                    LabeledContent("Unité") {
                        TextField("obligatoire", text: $unit)
                        
                    }
                }
                
                Section {
                    Toggle(isOn: $applyTVA, label: {
                        Text("Appliquer la TVA")
                    })
                    
                    if applyTVA {
                        LabeledContent("TVA") {
                            TextField("20%", value: $tva, format: .percent)
                        }
                        .multilineTextAlignment(.trailing)
                        
                        HStack {
                            Text("Montant TVA")
                            Spacer()
                            Text(prix * 0.20, format: .currency(code: "EUR"))
                        }
                    }
                }
                
                LabeledContent("Montant final", value: tot, format: .currency(code: "EUR"))
                    .multilineTextAlignment(.center)
                
//                Toggle("Faire de ce type d'acte votre type d'acte par defaut", isOn: $isDefault)
            }
            .formStyle(.grouped)
//            .headerProminence(.increased)
            .navigationTitle(typeActeToModify == nil ? "Nouveau type d'acte" : "Type d'acte : \(typeActeToModify!.name ?? "")")
            .toolbar {
                
                if onCancel != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Annuler", role: .destructive) {
                            onCancel?()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(onCancel != nil ? "OK" : "Termniné") {
                        modify()
                        
                        onSave?()
                    }
                    .disabled(disableForm)
                }
            }
        }
        .onAppear {
            if let typeActe = typeActeToModify {
                nom = typeActe.name ?? ""
                prix = typeActe.price
            }
        }
    }
    
    func modify() {
        let typeActe = typeActeToModify ?? TypeActe(context: moc)
        typeActe.version = FormTypeActeSheet.getVersion()
        
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
    FormTypeActeSheet()
}
