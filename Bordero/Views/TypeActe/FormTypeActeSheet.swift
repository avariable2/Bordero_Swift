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
    
    @State var applyTVA : Bool
    @State private var tauxTVA : Double = 0.20
    @State private var tot : Double = 0
    @State private var addFavoris = false
    
    private var disableForm: Bool {
        nom.isEmpty
    }
    
    init(applyTVA : Bool = false, typeActeToModify : TypeActe? = nil, onSave: (() -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        self.applyTVA = applyTVA
        self.onSave = onSave
        self.typeActeToModify = typeActeToModify
        self.onCancel = onCancel
    }
    
    var body: some View {
        NavigationStack {
            List {
                VStack(alignment: .center) {
                    Image(systemName: "stethoscope")
                        .font(.largeTitle)
                        .symbolRenderingMode(.multicolor)
                }
                .frame(maxWidth: .infinity)
                
                Section {
                    TextField("Nom", text: $nom)
                        .keyboardType(.default)
                       .multilineTextAlignment(.leading)
                    
                    LabeledContent("Prix") {
                        TextField("facultatif", value: $prix, format: .currency(code: "EUR"))
                    }
                    
                    Text("Description")
                        .foregroundStyle(.secondary)
                        .fontWeight(.light)
                        .listRowSeparator(.hidden, edges: .bottom)
                    
                    TextEditor(text: $description)
                        .lineSpacing(3)
                        .keyboardType(.default)
                        .multilineTextAlignment(.leading)
                }
                
                Section {
                    Toggle(isOn: $applyTVA, label: {
                        Text("Appliquer la TVA")
                    })
                    
                    if applyTVA {
                        LabeledContent("TVA") {
                            TextField("pourcentage de TVA", value: $tauxTVA, format: .percent)
                                .foregroundStyle(.indigo)
                        }
                        .multilineTextAlignment(.trailing)
                        
                        HStack {
                            Text("Montant TVA")
                            
                            Spacer()
                            
                            Text(calculerTVA(), format: .currency(code: "EUR"))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                LabeledContent("Montant final", value: applyTVA ? montantFinal() : prix, format: .currency(code: "EUR"))
                    .multilineTextAlignment(.center)
                    .bold()
            }
            .tint(.indigo)
            .listStyle(.grouped)
            .multilineTextAlignment(.trailing)
            .navigationTitle(typeActeToModify == nil ? "Nouveau type d'acte" : "Type d'acte : \(typeActeToModify!.name)")
            .toolbar {
                
                if onCancel != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Annuler", role: .destructive) {
                            onCancel?()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("OK") {
                        modify()
                        
                        onSave?()
                    }
                    .disabled(disableForm)
                }
            }
        }
        .onAppear {
            if let typeActe = typeActeToModify {
                nom = typeActe.name
                description = typeActe.info
                prix = typeActe.price
                
                applyTVA = typeActe.tva != 0
                tauxTVA = typeActe.tva
                tot = typeActe.total
                
            }
        }
    }
    
    func calculerTVA() -> Double {
        let montantTVA = prix * tauxTVA
        return montantTVA
    }
    
    func montantFinal() -> Double {
        return applyTVA ? prix * tauxTVA + prix : prix
    }
    
    func modify() {
        let typeActe = typeActeToModify ?? TypeActe(context: moc)
        typeActe.version = FormTypeActeSheet.getVersion()
        if typeActeToModify == nil {
            typeActe.id = UUID()
        }
        
        typeActe.name = nom
        typeActe.info = description
        typeActe.price = prix
        typeActe.tva = applyTVA ? tauxTVA : 0
        typeActe.total = montantFinal()
        
        save()
    }
    
    func save() {
        do {
            try moc.save()
            print("Success")
        } catch let err {
            print("error \(err)")
        }
        
        onSave?()
    }
}

#Preview {
    FormTypeActeSheet()
}
