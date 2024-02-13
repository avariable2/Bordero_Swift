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
            Section("Adresse de facturation") {
                LabeledContent("Pays") {
                    TextField("Pays", text: $pays)
                }
                LabeledContent("Rue") {
                    TextField("Rue", text: $rue)
                }
                LabeledContent("Code postal") {
                    TextField("Code postal", text: $codePostal)
                }
                LabeledContent("Ville") {
                    TextField("Ville", text: $ville)
                }
            }
            
            Section("Identification") {
                Toggle("Appliquer la TVA sur les factures", isOn: $applyTVA)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                LabeledContent("Numéro de SIRET") {
                    TextField("Numéro de SIRET", text: $siret)
                }
                LabeledContent("Numéro ADELI") {
                    TextField("Numéro ADELI", text: $adeli)
                }
            }
            
            Section("Contact") {
                LabeledContent("Prénom") {
                    TextField("Prénom", text: $nom)
                }
                LabeledContent("Nom") {
                    TextField("Nom", text: $prenom)
                }
                LabeledContent("Téléphone") {
                    TextField("Téléphone", text: $siret)
                }
                LabeledContent("E-mail") {
                    TextField("E-mail", text: $adeli)
                }
                LabeledContent("Site web") {
                    TextField("Site web", text: $adeli)
                }
            }
            
            NavigationLink {
                SignatureFormView()
            } label: {
                Label("Signature", systemImage: "signature")
            }
        }
        .multilineTextAlignment(.trailing)
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
