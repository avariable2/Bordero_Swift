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
    
    @State private var prix: Double = 0
    @State private var quantity: Double = 1
    @State private var unit : String = ""
    
    @State private var applyTVA = false
    @State private var tauxTVA : Double = 0
    @State private var tot : Decimal = 0
    @State private var isDefault = false
    
    private var disableForm: Bool {
        nom.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                HStack(alignment: .center) {
                    
                    Image(systemName: "cross.case.circle.fill")
                        .foregroundStyle(.white, .purple)
                        .frame(height: 80)
                        .font(.system(size: 60))
                }
                .frame(maxWidth: .infinity)
                
                Section {
                    TextField("Nom", text: $nom)
                        .keyboardType(.default)
                        .multilineTextAlignment(.leading)
                    
                    LabeledContent("Prix") {
                        TextField("facultatif", value: $prix, format: .currency(code: "EUR"))
                    }
                    
                    LabeledContent("Description") {
                        TextField("facultatif", text: $description)
                            .keyboardType(.default)
                    }
                }
                
                Section {
                    Toggle(isOn: $applyTVA, label: {
                        Text("Appliquer la TVA")
                    })
                    
                    if applyTVA {
                        LabeledContent("TVA") {
                            TextField("pourcentage de TVA", value: $tauxTVA, format: .percent)
                                .tint(.accentColor)
                        }
                        .multilineTextAlignment(.trailing)
                        
                        HStack {
                            Text("Montant TVA")
                            
                            Spacer()
                            
                            Text(calculerTVA(), format: .currency(code: "EUR"))
                        }
                    }
                }
                
                LabeledContent("Montant final", value: applyTVA ? prix * (tauxTVA/100) + prix : prix, format: .currency(code: "EUR"))
                    .multilineTextAlignment(.center)
                    .bold()
                
//                Toggle("Faire de ce type d'acte votre type d'acte par defaut", isOn: $isDefault)
            }
            .formStyle(.grouped)
            .multilineTextAlignment(.trailing)
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
    
    func calculerTVA() -> Double {
        let montantTVA = prix * (tauxTVA / Double(100))
        return montantTVA
    }
    
    func modify() {
        let typeActe = typeActeToModify ?? TypeActe(context: moc)
        typeActe.version = FormTypeActeSheet.getVersion()
        
        typeActe.name = nom
        typeActe.price = prix
        
        typeActe.unit = unit
//        typeActe.quantity = Int64(quantity)
        
        let tva = applyTVA ? tauxTVA : 0
        typeActe.tva = tva
//        type Acte.total = prix + (prix * tva)
        
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
