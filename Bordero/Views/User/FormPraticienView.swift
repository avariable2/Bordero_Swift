//
//  FormPraticienView.swift
//  Bordero
//
//  Created by Grande Variable on 12/02/2024.
//

import SwiftUI
import Contacts
import SwiftUIDigitalSignature
import PhotosUI

struct FormPraticienView: View, Saveable, Modifyable, Versionnable {
    static func getVersion() -> Int32 {
        return 1
    }
    
    // Create a unique and specif uuid for be sure all user has the same and can get her data from home
    static let uuidPraticien = UUID(uuidString: "62094590-C187-4F68-BE0D-D8E348299900")
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    // MARK: Textfield pour les coordoonées du praticien
    @State private var profilPicture : UIImage? = nil
    
    @State private var signature: UIImage? = nil
    @State private var showSheetForSignature = false
    
    @State private var nom = ""
    @State private var prenom = ""
    @State private var pays = "France"
    @State private var etageOrAppt = ""
    @State private var rue = ""
    @State private var codePostal = ""
    @State private var ville = ""
    
    @State private var selectedPhotoPicker: PhotosPickerItem?
    @State private var selectedPhotoSocieteUIImage: UIImage?
    @State private var nomSociete = ""
    @State private var applyTVA : Bool = true
    @State private var siret = ""
    @State private var adeli = ""
    
    @State private var email = ""
    @State private var numero = ""
    @State private var website = ""
    
    @State private var selectedContact: CNContact?
    @State private var showAlert = false
    
    // MARK: Option d'affichage du formulaire
    var isOnBoarding : Bool
    var titre = "Renseignements professionnel"
    var textFacultatif = "facultatif"
    
    @State var praticien : Praticien?
    var callback : (() -> Void)?
    
    var body: some View {
        Form {
            VStack(alignment: .center, spacing: 20) {
                
                ProfilImageView(imageData: profilPicture?.jpegData(compressionQuality: 1.0))
                    .frame(height: 80)
                    .font(.system(size: 60))
                
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
                    
                    profilPicture = nil
                    if contact.imageDataAvailable {
                        if let imageData = contact.thumbnailImageData, let uiImage = UIImage(data: imageData) {
                            profilPicture = uiImage
                            profilPicture!.jpegData(compressionQuality: 1.0)
                        }
                        
                    }
                    
                    prenom = contact.givenName
                    nom = contact.familyName
                    numero = contact.phoneNumbers.first?.value.stringValue ?? ""
                    email = String(contact.emailAddresses.first?.value ?? "")
                    
                    ville = contact.postalAddresses.first?.value.city ?? ""
                    rue = contact.postalAddresses.first?.value.street ?? ""
                    codePostal = contact.postalAddresses.first?.value.postalCode ?? ""
                    
                }
                .multilineTextAlignment(.leading)
                
            } footer: {
                Text("Pour gagner du temps importer les champs principaux comme votre nom ou prénom depuis votre fiche Contacts.")
                    .multilineTextAlignment(.leading)
            }
            
            Section {
                
                TextField("Nom de l'entreprise", text: $nomSociete)
                    .keyboardType(.default)
                    .multilineTextAlignment(.leading)
                
                ViewThatFits {
                    LabeledContent("Numéro de SIRET") {
                        TextField("Important", text: $siret)
                            .keyboardType(.numberPad)
                    }
                    
                    LabeledContent("SIRET") {
                        TextField("Important", text: $siret)
                            .keyboardType(.numberPad)
                    }
                }
                
                ViewThatFits {
                    LabeledContent("Numéro ADELI") {
                        TextField("Important", text: $adeli)
                            .keyboardType(.numberPad)
                    }
                    LabeledContent("ADELI") {
                        TextField("Important", text: $adeli)
                            .keyboardType(.numberPad)
                    }
                }
                
                ViewThatFits {
                    Toggle("Appliquer la TVA sur les factures", isOn: $applyTVA)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                        .sensoryFeedback(.success, trigger: applyTVA)
                    
                    VStack(alignment: .center) {
                        Text("Appliquer la TVA sur les factures")
                            .multilineTextAlignment(.leading)
                        
                        Toggle("", isOn: $applyTVA)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                            .sensoryFeedback(.success, trigger: applyTVA)
                    }
                }
                
            } header: {
                Text("Identification")
            } footer: {
                Text("Ces champs sont important ficalement pour que vos documents soient valides.")
                    .multilineTextAlignment(.leading)
            }
            
            Section {
                LabeledContent("Prénom") {
                    TextField(textFacultatif, text: $prenom)
                        .keyboardType(.alphabet)
                }
                LabeledContent("Nom") {
                    TextField(textFacultatif, text: $nom)
                        .keyboardType(.alphabet)
                }
                LabeledContent("Téléphone") {
                    TextField(textFacultatif, text: $numero)
                        .keyboardType(.phonePad)
                }
                LabeledContent("E-mail") {
                    TextField(textFacultatif, text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                LabeledContent("Site web") {
                    TextField(textFacultatif, text: $website)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
            } header: {
                Text("Contact")
            } footer: {
                Text("Tous les champs sont facultatifs mais vos documents manqueront d'informations. Il est de votre devoir d'être transparents sur vos informations pour vous identifier correctement sur un document.")
                    .multilineTextAlignment(.leading)
            }
            
            Section("Adresse de facturation") {
                
                LabeledContent("Rue") {
                    TextField(textFacultatif, text: $rue)
                        .keyboardType(.default)
                }
                
                LabeledContent("Étage, appt.") {
                    TextField(textFacultatif, text: $etageOrAppt)
                        .keyboardType(.default)
                }
                
                LabeledContent("Code postal") {
                    TextField(textFacultatif, text: $codePostal)
                        .keyboardType(.numberPad)
                }
                
                LabeledContent("Ville") {
                    TextField(textFacultatif, text: $ville)
                        .keyboardType(.default)
                }
                
            }
            
            Section {
                Button {
                    showSheetForSignature.toggle()
                } label: {
                    Label("Signature", systemImage: "signature")
                }
                .sheet(isPresented: $showSheetForSignature) {
                    SignatureViewCustom(availableTabs: [.draw, .image, .type]) { signature in
                        self.signature = signature
                        showSheetForSignature.toggle()
                    } onCancel: {
                        showSheetForSignature.toggle()
                    }
                }
                
                if let sign = signature {
                    Image(uiImage: sign)
                        .resizable()
                        .scaledToFit()
                }
            }
            
            Section {
                PhotosPicker(selection: $selectedPhotoPicker, matching: .images, photoLibrary: .shared()) {
                    Label(selectedPhotoSocieteUIImage != nil ? "Modifier le logo de société" : "Ajouter un logo de société", systemImage: "photo")
                }
                .onChange(of: selectedPhotoPicker) { oldItem, newItem in
                    Task {
                        // Retrive selected asset in the form of Data
                        if let loaded = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedPhotoSocieteUIImage = UIImage(data: loaded)
                        }
                    }
                }
                
                if let selectedImage = selectedPhotoSocieteUIImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .onAppear {
            if let user = praticien {
                retrieveInfoFormPraticienNotNull(user)
            }
        }
        .navigationTitle(isOnBoarding ? "" : titre)
        .navigationBarTitleDisplayMode(isOnBoarding ? .automatic : .inline)
        .headerProminence(.increased)
        .multilineTextAlignment(.trailing)
        .background(Color(.systemGray6))
        .toolbar {
            if !isOnBoarding {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        modify()
                        dismiss()
                    } label: {
                        Text("OK")
                    }
                }
            }
        }
        .alert("Les données ne seront pas sauvegarder", isPresented: $showAlert, actions: {
            Button("Quitter", role: .destructive) {
                dismiss()
            }
            
            Button {
                modify()
            } label :{
                Text("Sauvegarder")
            }
        })
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
        let _ = createPraticienObject()
        
        save()
    }
    
    func createPraticienObject() -> Praticien {
        let praticien = praticien ?? Praticien(context: moc)
        
        praticien.id = FormPraticienView.uuidPraticien!
        praticien.version = FormPraticienView.getVersion()
        
        praticien.profilPicture = profilPicture?.jpegData(compressionQuality: 1.0)
        praticien.logoSociete = selectedPhotoSocieteUIImage?.jpegData(compressionQuality: 1.0)
        
        praticien.nom_proffession = nomSociete
        praticien.adeli = adeli
        praticien.siret = siret
        praticien.applyTVA = applyTVA
        
        praticien.firstname = prenom
        praticien.lastname = nom
        praticien.email = email
        praticien.phone = numero
        praticien.website = website
        
        modifiyAdresseToPraticien(praticien)
        
        praticien.signature = signature?.jpegData(compressionQuality: 1)
        
        return praticien
    }
    
    func modifiyAdresseToPraticien(_ praticien : Praticien) {
        praticien.adresse1 = [
            "rue" : rue,
            "etage_appt" : "",
            "code_postal" : codePostal,
            "ville" : ville,
            "province_etat" : "",
            "pays" : ""
        ]
    }
    
    func retrieveInfoFormPraticienNotNull(_ user : Praticien) {
        if let data = user.profilPicture {
            profilPicture = UIImage(data: data) ?? nil
        }
        
        nomSociete = user.nom_proffession ?? ""
        adeli = user.adeli
        siret = user.siret 
        applyTVA = user.applyTVA
        
        prenom = user.firstname 
        nom = user.lastname 
        email = user.email 
        numero = user.phone 
        website = user.website
        
        if let dataSignature = user.signature, let uiImage = UIImage(data: dataSignature) {
            signature = uiImage
        }
        
        if let dataLogoSociete = user.logoSociete, let uiImage = UIImage(data: dataLogoSociete) {
            selectedPhotoSocieteUIImage = uiImage
        }
        
        if let adresse = user.adresse1 {
            
            codePostal = adresse["code_postal"] as? String ?? ""
            rue = adresse["rue"] as? String ?? ""
            ville = adresse["ville"] as? String ?? ""
            etageOrAppt = adresse["etage_appt"] as? String ?? ""
        }
    }
}

#Preview {
    FormPraticienView(isOnBoarding: false)
}
