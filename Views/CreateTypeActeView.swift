//
//  CreateTypeActeView.swift
//  Bordero
//
//  Created by Grande Variable on 05/02/2024.
//

import SwiftUI

struct CreateTypeActeView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    @Binding var showingAlert: Bool
    
    @State private var nom : String = ""
    @State private var numberString: String = ""
    @State private var floatValue: Float?
    
    private var disableForm: Bool {
        nom.isEmpty || floatValue == nil
    }
    
    var body: some View {
        ZStack {
            
            Color
                .white
                .ignoresSafeArea()
                .overlay(.ultraThinMaterial)
            
            VStack(alignment: .center, spacing: 20) {
                 
                Text("Creer un type d'acte")
                    .font(.title)
                    .bold()
                
                VStack(spacing: 20) {
                    TextField("Entrer un nom", text: $nom)
                        
                        
                    TextField("Entrer un prix", text: $numberString)
                        .keyboardType(.decimalPad)
                        .onChange(of: numberString) {
                            validateNumberString()
                        }
                    
                    
                }
                .textFieldStyle(.roundedBorder)
                .padding([.trailing, .leading], 20)
                
                VStack(spacing: 30) {
                    
                    Button("Créer") {
                        creerTypeActe()
                        showingAlert.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(disableForm)
                    
                    
                    Button("Annuler", role: .destructive) {
                        numberString = ""
                        floatValue = nil
                        nom = ""
                        showingAlert.toggle()
                    }
                }
                
            }
        }
    }
    
    private func validateNumberString() {
        if let value = Float(numberString) {
           // Si la conversion réussit, mettre à jour le state Float
           floatValue = value
       } else {
           // Réinitialiser le state Float si la chaîne n'est pas un nombre valide
           floatValue = nil
       }
    }
    
    private func creerTypeActe() {
        guard let prix = floatValue else {
            print("Il y'a une erreur avec la valeur set dans la modal")
            return
        }
        
        let typeActe = TypeActe(context: moc)
        typeActe.id = UUID()
        typeActe.name = nom
        typeActe.price = prix
        
        do {
            try moc.save()
            print("Success")
        } catch let err {
            print(err.localizedDescription)
        }
        
    }
}

#Preview {
    CreateTypeActeView(showingAlert: .constant(true))
}
