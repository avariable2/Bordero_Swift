//
//  FormPraticienView.swift
//  Bordero
//
//  Created by Grande Variable on 12/02/2024.
//

import SwiftUI
import Contacts

struct FormPraticienView: View, Saveable, Modifyable {
    
    static let idAdressePraticien = UUID()
    
    @Environment(\.managedObjectContext) var moc
    
    // MARK: Textfield pour les coordoonées du praticien
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
    
    // MARK: Option d'affichage du formulaire
    var isOnBoarding : Bool
    var titre = "Renseignements professionnel"
    var textFacultatif = "Facultatif"
    
    var praticien : Praticien?
    var callback : (() -> Void)?
    
    
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
                    TextField(textFacultatif, text: $numero)
                }
                LabeledContent("E-mail") {
                    TextField(textFacultatif, text: $email)
                }
                LabeledContent("Site web") {
                    TextField(textFacultatif, text: $website)
                }
            } header: {
                Text("Contact")
            } footer: {
                Text("Tous les champs sont facultatifs mais vos documents manqueront d'informations. Il est de votre devoir d'être transparents sur vos informations pour vous identifier correctement sur un document.")
                    .multilineTextAlignment(.leading)
            }
            
            Section("Adresse de facturation") {
//                LabeledContent("Pays") {
//                    TextField(textFacultatif, text: $pays)
//                }
                
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
        .multilineTextAlignment(.trailing)
        .background(Color(.systemGray6))
        .safeAreaInset(edge: .bottom) {
            if isOnBoarding {
                Button {
                    modify()
                } label: {
                    Text("Suivant")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
            }
        }
    }
    
    func save() {
        do {
            try moc.save()
            
            print("Success")
            
            if let action = callback {
                action()
            }
        } catch let err {
            print("error \(err)")
        }
    }
    
    func modify() {
        let praticien = Praticien(context: moc)
        praticien.profilPicture = image?.jpegData(compressionQuality: 1.0)
        
        praticien.adeli = adeli
        praticien.siret = siret
        praticien.applyTVA = applyTVA
        
        praticien.firstname = prenom
        praticien.lastname = nom
        praticien.email = email
        praticien.phone = numero
        praticien.website = website
        
        modifiyAdresseToPraticien(praticien)
        
        save()
    }
    
    func modifiyAdresseToPraticien(_ praticien : Praticien) {
        let adressePraticien = Adresse(context: moc)
        adressePraticien.id = FormPraticienView.idAdressePraticien
        adressePraticien.codepostal = codePostal
        adressePraticien.appartient = praticien
        adressePraticien.rue = rue
        adressePraticien.ville = ville
    }
}

#Preview {
    FormPraticienView(isOnBoarding: true)
}
