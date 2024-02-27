//
//  FormClientView.swift
//  Bordero
//
//  Created by Grande Variable on 05/02/2024.
//

import SwiftUI
import Contacts

struct TTLAdresse : Identifiable {
    var id : UUID = UUID()
    var rue: String = ""
    var ville: String = ""
    var codePostal: String = ""
}

struct FormClientView: View, Saveable, Modifyable, Versionnable {
    enum FocusedField : Hashable {
        case firstName, lastName, phone
    }
    
    // MARK: - Versionning des possibles mise a jour de l'entity
    static func getVersion() -> Int32 {
        return 1
    }
    
    @Environment(\.managedObjectContext) var moc
    
    // MARK: - Binding pour afficher la création ou modification d'un client
    @Binding var activeSheet: ActiveSheet?
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
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Prénom", text: $prenom)
                        .keyboardType(.namePhonePad)
                        .focused($focusedField, equals: .firstName)
                    
                    TextField("Nom", text: $nom)
                        .keyboardType(.namePhonePad)
                        .focused($focusedField, equals: .lastName)
                }
                
                Section {
                    TextField("Ajouter un numero", text: $numero)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                        .focused($focusedField, equals: .phone)
                }
                
                Section {
                    TextField("Ajouter un email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                
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
                            Label("Ajouter une addresse", systemImage: "plus")
                        }
                    }
                } footer: {
                    Text("Pour supprimer une addresse, il vous suffit de la faire glisser sur la gauche et de clicquer sur supprimer.")
                }
                
                // MARK: - Partie pour importer les contacts depuis l'iphone de l'utilisateur. Incompatible avec AppleWatch.
                ImportContactView(
                    selectedContact: $selectedContact
                ) {
                    Label {
                        Text("Importer depuis vos Contacts")
                    } icon: {
                        Image(systemName: "person.crop.circle.fill.badge.plus")
                            
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler", role: .destructive) {
                        activeSheet = nil
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("OK") {
                        modify()
                    }
                }
            }
            .navigationTitle(clientToModify == nil ? "Nouveau client" : "Client")
            .alert(Text("Une erreur s'est produite"),
                    isPresented: $showingAlert,
                    actions: {
                        Button("OK", role: .cancel) { 
                            showingAlert = false
                        }
                    }, message: {
                        Text("Réessayer. Si cette erreur persiste, veuillez contacter le support.")
                    }
                )
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
    
    func save() {
        do {
            try moc.save()
            
            print("Success")
            activeSheet = nil
            
        } catch let err {
            showingAlert = true
            print(err.localizedDescription)
        }
    }
    
    func modify() {
        let client = clientToModify ?? Client(context: moc)
        client.version = FormClientView.getVersion()
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
}

#Preview {
    FormClientView(activeSheet: .constant(.createClient))
}
