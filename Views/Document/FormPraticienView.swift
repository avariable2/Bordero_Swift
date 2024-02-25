//
//  FormPraticienView.swift
//  Bordero
//
//  Created by Grande Variable on 12/02/2024.
//

import SwiftUI

struct FormPraticienView: View {
    
    private var titre = "Renseignements professionnel"
    private var textFacultatif = "Facultatif"
    
    @State private var nom = ""
    @State private var prenom = ""
    @State private var pays = ""
    @State private var rue = ""
    @State private var codePostal = ""
    @State private var ville = ""
    
    @State private var applyTVA : Bool = true
    @State private var siret = ""
    @State private var adeli = ""
    
    private var isOnBoarding : Bool
    
    init(isOnBoarding : Bool) {
        self.isOnBoarding = isOnBoarding
    }
    
    var body: some View {
        VStack {
            
            Form {
                
                VStack(alignment: .center, spacing: 20) {
                    
//                    Image(systemName: "person.crop.circle.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundStyle(.gray, .blue)
//                        .frame(height: 60)
                    
                    ZStack {
                        Circle()
                            .fill(Color.pink)
                            .frame(height: 80)
                        
                        Text("😃")
                            .font(.system(size: 60))
                    }
                    
                    if isOnBoarding {
                        Text("Configurer les renseignements \n professionnels")
                            .font(.title)
                            .bold()
                        
                        Text("Vos renseignements professionnels correspondent aux informations élémentaires dont l'app a besoin pour respecter au mieux les normes de l'édition de documents administratifs.")
                            .padding(.horizontal)
                    }
                    
                    
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                
                Section {
                    Button {
                        
                    } label: {
                        Label(
                            title: {
                                Text("Importer vos informations depuis votre fiche Contacts")
                                    .multilineTextAlignment(.center)
                            },
                            icon: {
                                Image(systemName: "person.crop.circle.fill")
                                    .foregroundStyle(.white, .primary)
                            }
                        )
                    }
                } footer: {
                    Text("Pour gagner du temps importer les champs principaux comme votre nom ou prénom depuis votre fiche Contacts.")
                        .multilineTextAlignment(.leading)
                }
                
                Section {
                    Toggle("Appliquer la TVA sur les factures", isOn: $applyTVA)
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                    
                    LabeledContent("Numéro de SIRET") {
                        TextField("Important", text: $siret)
                    }
                    LabeledContent("Numéro ADELI") {
                        TextField("Important", text: $adeli)
                    }
                } header: {
                    Text("Identification")
                } footer: {
                    Text("Ces champs sont obligatoires pour que votre documents soit valides.")
                        .multilineTextAlignment(.leading)
                }
                
                NavigationLink {
                    SignatureFormView()
                } label: {
                    Label("Signature", systemImage: "signature")
                }
                
                Section {
                    LabeledContent("Prénom") {
                        TextField(textFacultatif, text: $nom)
                    }
                    LabeledContent("Nom") {
                        TextField(textFacultatif, text: $prenom)
                    }
                    LabeledContent("Téléphone") {
                        TextField(textFacultatif, text: $siret)
                    }
                    LabeledContent("E-mail") {
                        TextField(textFacultatif, text: $adeli)
                    }
                    LabeledContent("Site web") {
                        TextField(textFacultatif, text: $adeli)
                    }
                } header: {
                    Text("Contact")
                } footer: {
                    Text("Tous les champs sont facultatifs mais vos documents manqueront d'informations. Il est de votre devoir d'être transparents sur vos informations pour vous identifier correctement sur un document.")
                        .multilineTextAlignment(.leading)
                }
                
                Section("Adresse de facturation") {
                    LabeledContent("Pays") {
                        TextField(textFacultatif, text: $pays)
                    }
                    LabeledContent("Rue") {
                        TextField(textFacultatif, text: $rue)
                    }
                    LabeledContent("Code postal") {
                        TextField(textFacultatif, text: $codePostal)
                    }
                    LabeledContent("Ville") {
                        TextField(textFacultatif, text: $ville)
                    }
                }
                
                
            }
            .navigationTitle(titre)
            .navigationBarHidden(isOnBoarding)
        }
        .multilineTextAlignment(.trailing)
        .background(Color(.systemGray6))
    }
}

#Preview {
    FormPraticienView(isOnBoarding: true)
}
