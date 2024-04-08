//
//  FormClientView.swift
//  Bordero
//
//  Created by Grande Variable on 05/02/2024.
//

import SwiftUI
import Contacts

struct FormClientSheet: View, Saveable, Modifyable, Versionnable {
    enum FocusedField : Hashable {
        case firstName, lastName, phone
    }
    
    // MARK: - Versionning des possibles mise a jour de l'entity
    static func getVersion() -> Int32 {
        return 1
    }
    
    @Environment(\.managedObjectContext) var moc
    
    // MARK: - State uniquement pour l'affichage d'une erreur
    var onCancel: (() -> Void)?
    var onSave: (() -> Void)?
    
    // MARK: - Binding pour afficher la création ou modification d'un client
    @State var clientToModify : Client?
    
    // MARK: - State uniquement pour l'affichage d'une erreur
    @State private var showingAlert: Bool = false
    
    // MARK: - Input pour l'utilisateur
    @State var nom : String = ""
    @State var prenom : String = ""
    @State var adresse : String = ""
    @State var codePostal : String = ""
    @State var ville : String = ""
    @State var numero : String = ""
    @State var email : String = ""
    
    // MARK: - Contact et adresse gestion
    @State private var selectedContact: CNContact?
    @State private var adresses: [TTLAdresse] = []
    
    // MARK: - Focus gestion
    @FocusState private var focusedField : FocusedField?
    
    var callbackOnDelete : (() -> Void)?
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .center) {
                    
                    ProfilImageView(imageData: nil)
                        .frame(height: 80)
                        .font(.system(size: 60))
                }
                .frame(maxWidth: .infinity)
                
                // MARK: - Partie pour importer les contacts depuis l'iphone de l'utilisateur. Incompatible avec AppleWatch.
                Section {
                    ImportContactView(
                        selectedContact: $selectedContact
                    ) {
                        Label {
                            Text("Importer depuis vos Contacts")
                        } icon: {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .foregroundStyle(.blue, .gray, .white)
                        }
                    }
                    .onChange(of: selectedContact) {
                        guard let contact = selectedContact else {
                            return
                        }
                        
                        prenom = contact.givenName
                        nom = contact.familyName
                        numero = contact.phoneNumbers.first?.value.stringValue ?? ""
                        email = String(contact.emailAddresses.first?.value ?? "")
                        
                        for address in contact.postalAddresses {
                            let infoAdress = address.value
                            
                            let rue = infoAdress.street
                            let ville = infoAdress.city
                            let codepostal = infoAdress.postalCode
                            
                            let nouvelleAdresse = TTLAdresse(rue: rue, ville : ville, codePostal: codepostal)
                            adresses.append(nouvelleAdresse)
                        }
                    }
                }
                
                Section {
                    TextField("Prénom", text: $prenom)
                        .keyboardType(.namePhonePad)
                        .focused($focusedField, equals: .firstName)
                    
                    TextField("Nom", text: $nom)
                        .keyboardType(.namePhonePad)
                        .focused($focusedField, equals: .lastName)
                }
                
                Section {
                    LabeledContent {
                        TextField("facultatif", text: $numero)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                            .focused($focusedField, equals: .phone)
                    } label: {
                        ViewThatFits {
                            Text("Numero de téléphone")
                            Text("Téléphone")
                        }
                    }
                }
                .multilineTextAlignment(.trailing)
                
                Section {
                    LabeledContent {
                        TextField("facultatif", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                    } label: {
                        ViewThatFits {
                            Text("Adresse e-mail")
                            Text("E-mail")
                        }
                    }
                }
                .multilineTextAlignment(.trailing)
                
                Section {
                    List {
                        ForEach(adresses.indices, id : \.self) { index in
                            HStack {
                                
                                Text("Adresse \(index + 1)")
                                
                                VStack {
                                    TextField("Rue", text: $adresses[index].rue)
                                    TextField("Ville", text: $adresses[index].ville)
                                    TextField("Code Postal", text: $adresses[index].codePostal)
                                }
                            }
                            
                        }
                        .onDelete(perform: { indexSet in
                            adresses.remove(atOffsets: indexSet)
                        })
                        
                        Button {
                            withAnimation {
                                let nouvelleAdresse = TTLAdresse()
                                adresses.append(nouvelleAdresse)
                            }
                        } label: {
                            Label {
                                Text("ajouter une adresse")
                                    .tint(.primary)
                            } icon: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.white, .green)
                            }
                        }
                    }
                } footer: {
                    Text("Pour supprimer une addresse, il vous suffit de la faire glisser sur la gauche et de clicquer sur supprimer.")
                }
                
                if let _ = callbackOnDelete {
                    Button(role: .destructive) {
                        delete()
                    } label: {
                        Text("Supprimer le client")
                        
                    }
                }
                
            }
            .onSubmit {
                switch focusedField {
                case .firstName:
                    focusedField = .lastName
                case .lastName:
                    focusedField = .phone
                default:
                    break
                }
            }
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
                    }
                    .disabled(!isAtLeastOneFieldFilled())
                }
            }
            .navigationTitle(clientToModify == nil ? "Nouveau client" : "\(prenom.capitalized) \(nom.uppercased())")
            .alert(Text("Une erreur s'est produite"),
                   isPresented: $showingAlert,
                   actions: {
                Button("OK", role: .cancel) {
                    showingAlert = false
                }
            }, message: {
                Text("Réessayer. Si cette erreur persiste, veuillez contacter le développeur depuis les paramètres.")
            })
            .onAppear {
                guard let client = clientToModify else { return }
                prenom = client.firstname ?? ""
                nom = client.name ?? ""
                numero = client.phone ?? ""
                email = client.email ?? ""
                
                if client.adresses != nil {
                    for address in client.adresses! {
                        let infoAdress = address as! Adresse
                        
                        let rue = infoAdress.rue
                        let ville = infoAdress.ville
                        let codepostal = infoAdress.codepostal
                        
                        let nouvelleAdresse = TTLAdresse(rue: rue!, ville : ville!, codePostal: codepostal!)
                        adresses.append(nouvelleAdresse)
                    }
                }
                
            }
        }
        
    }
    
    func isAtLeastOneFieldFilled() -> Bool {
        let fields = [nom, prenom]
        
        return fields.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    
    func save() {
        do {
            try moc.save()
            onSave?()
        } catch _ {
            showingAlert = true
        }
    }
    
    func modify() {
        let client = clientToModify ?? Client(context: moc)
        client.version = FormClientSheet.getVersion()
        if clientToModify == nil {
            client.id = UUID()
        }
        
        client.name = nom
        client.firstname = prenom
        client.email = email
        client.phone = numero
        
        let tab = client.adresses?.mutableCopy() as! NSMutableSet
        tab.removeAllObjects()
        
        client.adresses = tab
        
        for ttl in adresses {
            client.adresses?.adding(createAdresse(ttl, client: client))
        }
        
        save()
    }
    
    private func createAdresse(_ ttl : TTLAdresse, client : Client) {
        let userAdresse = Adresse(context: moc)
        userAdresse.id = UUID()
        userAdresse.rue = ttl.rue
        userAdresse.codepostal = ttl.codePostal
        userAdresse.ville = ttl.ville
        userAdresse.occupant = client
    }
    
    func delete() {
        guard let client = clientToModify else { return }
        moc.delete(client)
        
        do {
            try moc.save()
            if let call = callbackOnDelete {
                call()
            }
            onCancel?()
        } catch {
            print("Échec de la suppression du client: \(error.localizedDescription)")
            // Gérer l'erreur de manière appropriée
        }
    }
}

struct TTLAdresse : Identifiable {
    var id : UUID = UUID()
    var rue: String = ""
    var ville: String = ""
    var codePostal: String = ""
}

#Preview {
    FormClientSheet()
}
