//
//  FormPraticienView.swift
//  Bordero
//
//  Created by Grande Variable on 12/02/2024.
//

import SwiftUI
import Contacts

struct FormPraticienView: View {
    
    private var titre = "Renseignements professionnel"
    private var textFacultatif = "Facultatif"
    
    @State private var image : UIImage? = nil
    
    @State private var nom = ""
    @State private var prenom = ""
    @State private var pays = ""
    @State private var rue = ""
    @State private var codePostal = ""
    @State private var ville = ""
    
    @State private var applyTVA : Bool = true
    @State private var siret = ""
    @State private var adeli = ""
    
    @State private var email = ""
    @State private var numero = ""
    @State private var website = ""
    
    @State private var selectedContact: CNContact?
    
    private var isOnBoarding : Bool
    
    init(isOnBoarding : Bool) {
        self.isOnBoarding = isOnBoarding
    }
    
    var body: some View {
        Form {
            
            VStack(alignment: .center, spacing: 20) {
                
                if image != nil {
                    
                    Image(uiImage: image!)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .clipShape(Circle())
                    
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.white, .gray)
                        .imageScale(.large)
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
                ImportContactView(
                    selectedContact: $selectedContact
                ) {
                    HStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.fill")
                            .imageScale(.large)
                        
                        Text("Importer vos informations depuis votre fiche Contacts")
                    }
                }
                .onChange(of: selectedContact) {
                    guard let contact = selectedContact else {
                        return
                    }
                    
                    if contact.imageDataAvailable {
                        if let imageData = contact.thumbnailImageData, let uiImage = UIImage(data: imageData) {
                            image = uiImage
                            image!.jpegData(compressionQuality: 1.0)
                        }
                        
                    }
                    
                    prenom = contact.givenName
                    nom = contact.familyName
                    numero = contact.phoneNumbers.first?.value.stringValue ?? ""
                    email = String(contact.emailAddresses.first?.value ?? "")
                    
                }
                .multilineTextAlignment(.leading)
                
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
                Text("Ces champs sont important ficalement pour que vos documents soient valides.")
                    .multilineTextAlignment(.leading)
            }
            
            NavigationLink {
                SignatureFormView()
            } label: {
                Label("Signature", systemImage: "signature")
            }
            
            Section {
                LabeledContent("Prénom") {
                    TextField(textFacultatif, text: $prenom)
                }
                LabeledContent("Nom") {
                    TextField(textFacultatif, text: $nom)
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
        .navigationTitle(isOnBoarding ? "" : titre)
//            .navigationBarHidden(isOnBoarding)
        .multilineTextAlignment(.trailing)
        .background(Color(.systemGray6))
//        .scrollContentBackground(isOnBoarding ? .hidden : .visible)
    }
}

#Preview {
    FormPraticienView(isOnBoarding: true)
}
