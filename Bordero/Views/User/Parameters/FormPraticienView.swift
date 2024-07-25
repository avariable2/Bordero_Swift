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
import CoreData

struct FormPraticienView: View, Saveable, Modifyable, Versionnable {
    static func getVersion() -> Int32 {
        return 1
    }
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    // MARK: Textfield pour les coordoonées du praticien
    @State private var profilPicture : UIImage? = nil
    
    @State private var signature: UIImage? = nil
    @State private var showSheetForSignature = false
    
    @State private var pays = "France"
    @State private var etageOrAppt = ""
    @State private var rue = ""
    @State private var codePostal = ""
    @State private var ville = ""
    
    @State private var selectedPhotoPicker: PhotosPickerItem?
    @State private var selectedPhotoSocieteUIImage: UIImage?
    
    @State private var selectedContact: CNContact?
    @State private var showAlert = false
    
    // MARK: Option d'affichage du formulaire
    
    var titre = "Renseignements professionnels"
    var textFacultatif = "facultatif"
    
    @State var praticien : Praticien
    var callback : (() -> Void)?
    
    var body: some View {
        List {
            VStack(alignment: .center, spacing: 20) {
                ProfilImageView(imageData: praticien.profilPicture)
                    .frame(height: 80)
                    .font(.system(size: 60))
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
                            praticien.profilPicture = uiImage.pngData()
                        }
                        
                    }
                    
                    praticien.firstname = contact.givenName
                    praticien.lastname = contact.familyName
                    praticien.phone = contact.phoneNumbers.first?.value.stringValue ?? ""
                    praticien.email = String(contact.emailAddresses.first?.value ?? "")
                    
                    ville = contact.postalAddresses.first?.value.city ?? ""
                    rue = contact.postalAddresses.first?.value.street ?? ""
                    codePostal = contact.postalAddresses.first?.value.postalCode ?? ""
                    
                }
                .multilineTextAlignment(.leading)
                
            } footer: {
                Text("Pour gagner du temps, importez les champs principaux comme votre nom ou prénom depuis votre fiche Contacts.")
                    .multilineTextAlignment(.leading)
            }
            
            Section {
                
                TextField("Nom de l'entreprise", text: $praticien.nomEntreprise)
                    .keyboardType(.default)
                    .multilineTextAlignment(.leading)
                
                ViewThatFits {
                    LabeledContent("Numéro de SIRET") {
                        TextField("Important", text: $praticien.siret)
                            .keyboardType(.numberPad)
                    }
                    
                    LabeledContent("SIRET") {
                        TextField("Important", text: $praticien.siret)
                            .keyboardType(.numberPad)
                    }
                }
                
                ViewThatFits {
                    LabeledContent("Numéro ADELI") {
                        TextField("Important", text: $praticien.adeli)
                            .keyboardType(.numberPad)
                    }
                    LabeledContent("ADELI") {
                        TextField("Important", text: $praticien.adeli)
                            .keyboardType(.numberPad)
                    }
                }
                
                ViewThatFits {
                    Toggle("Appliquer la TVA sur les factures", isOn: $praticien.applyTVA)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                        .sensoryFeedback(.success, trigger: praticien.applyTVA)
                    
                    VStack(alignment: .center) {
                        Text("Appliquer la TVA sur les factures")
                            .multilineTextAlignment(.leading)
                        
                        Toggle("", isOn: $praticien.applyTVA)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                            .sensoryFeedback(.success, trigger: praticien.applyTVA)
                    }
                }
                
            } header: {
                Text("Identification")
            } footer: {
                Text("Ces champs sont importants fiscalement pour que vos documents soient valides.")
                    .multilineTextAlignment(.leading)
            }
            
            Section {
                LabeledContent("Prénom") {
                    TextField(textFacultatif, text: $praticien.firstname)
                        .keyboardType(.alphabet)
                }
                LabeledContent("Nom") {
                    TextField(textFacultatif, text: $praticien.lastname)
                        .keyboardType(.alphabet)
                }
                LabeledContent("Téléphone") {
                    TextField(textFacultatif, text: $praticien.phone)
                        .keyboardType(.phonePad)
                }
                LabeledContent("E-mail") {
                    TextField(textFacultatif, text: $praticien.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                LabeledContent("Site web") {
                    TextField(textFacultatif, text: $praticien.website)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
            } header: {
                Text("Contact")
            } footer: {
                Text("Tous les champs sont facultatifs, mais vos documents manqueront d'informations. Il est de votre devoir d'être transparents sur vos informations pour vous identifier correctement sur un document.")
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
                
                if selectedPhotoSocieteUIImage != nil {
                    Button {
                        withAnimation {
                            selectedPhotoSocieteUIImage = nil
                        }
                    } label: {
                        Label("Supprimer le logo", systemImage: "x.circle")
                            .foregroundStyle(.red)
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
            retrieveInfoFormPraticienNotNull(praticien)
        }
        .headerProminence(.increased)
        .multilineTextAlignment(.trailing)
        .background(Color(.systemGray6))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    modify()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Retour")
                    }
                }
            }
        }
        .alert("Les données ne seront pas sauvegardées", isPresented: $showAlert, actions: {
            Button("Quitter", role: .destructive) {
                dismiss()
            }
            
            Button {
                modify()
            } label :{
                Text("Sauvegarder")
            }
        })
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
        praticien.version = FormPraticienView.getVersion()
        
        praticien.modificationDate = Date()
        
        praticien.profilPicture = profilPicture?.jpegData(compressionQuality: 1.0)
        praticien.logoSociete = selectedPhotoSocieteUIImage?.jpegData(compressionQuality: 1.0)
        
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
    FormPraticienView(praticien: Praticien.example)
}
