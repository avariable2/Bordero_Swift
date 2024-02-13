//
//  FormPraticienView.swift
//  Bordero
//
//  Created by Grande Variable on 12/02/2024.
//

import SwiftUI

struct FormPraticienView: View {
    
    @State private var nomProfession = "Coordonnées"
    @State private var nom = ""
    @State private var prenom = ""
    @State private var pays = ""
    @State private var rue = ""
    @State private var codePostal = ""
    @State private var ville = ""
    
    @State private var applyTVA : Bool = true
    @State private var siret = ""
    @State private var adeli = ""
    
    var body: some View {
        Form {
//            Section("N") {
//                TextField("", text: $nomProfession)
//            }
            
            Section("Adresse de facturation") {
                TextField("Pays", text: $pays)
                TextField("Rue", text: $rue)
                TextField("Code postal", text: $codePostal)
                TextField("Ville", text: $ville)
                
            }
            
            Section("Identification") {
                Toggle("Appliquer la TVA sur les factures", isOn: $applyTVA)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                TextField("Numéro de SIRET", text: $siret)
                TextField("Numéro ADELI", text: $adeli)
            }
            
            Section("Contact") {
                TextField("Prénom", text: $nom)
                TextField("Nom", text: $prenom)
                TextField("Téléphone", text: $siret)
                TextField("E-mail", text: $adeli)
                TextField("Site web", text: $adeli)
            }
            
            NavigationLink {
                SignatureFormView()
            } label: {
                Label("Signature", systemImage: "signature")
            }
        }
        .navigationTitle(nomProfession)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    
                } label: {
                    Text("Sauvegarder")
                }
            }
        }
    }
}

#Preview {
    FormPraticienView()
}
