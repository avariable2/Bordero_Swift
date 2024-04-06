//
//  FormDocumentView.swift
//  Bordero
//
//  Created by Grande Variable on 12/02/2024.
//

import SwiftUI
import ScrollableGradientBackground

struct FormDocumentView: View {
    var body: some View {
        NavigationStack {
            ModifierDocumentView()
        }
        
    }
}

struct ModifierDocumentView: View, Saveable, Versionnable {
    enum TypeDoc : String, CaseIterable, Identifiable {
        case facture, devis
        
        var id: Self { self }
    }
    
    enum Payement : String, CaseIterable, Identifiable {
        case carte, especes, virement, cheque
        
        var id : Self { self }
        var rawValue: String {
            switch self {
            case .carte:
                "Carte"
            case .especes:
                "Espèces"
            case .virement:
                "Virement bancaire"
            case .cheque:
                "Chèque"
            }
        }
    }
    
    static func getVersion() -> Int32 {
        return 1
    }
    
    @State private var activeSheet: ActiveSheet?
    
    @State private var clients = [Client]()
    @State private var listTypeActes = [TTLTypeActe]()
    
    @State private var docIsFacture: Bool = true
    @State private var estPayer: Bool = false
    @State private var selectedPayement : Payement = .carte
    @State private var notes: String = ""
    @State private var typeSelected : TypeDoc = .facture
    
    @State var numero : String = "001"
    
    var body: some View {
        Form {
            Section {
                Picker("Type de document", selection: $typeSelected.animation()) {
                    ForEach(TypeDoc.allCases) { type in
                        Text(type.rawValue.capitalized)
                            .font(.title)
                    }
                }
                .pickerStyle(.segmented)
                
                LabeledContent("Numéro de \(typeSelected.rawValue.capitalized):") {
                    TextField("001", text: $numero.animation())
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 150)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Section {
                Button {
                    activeSheet = .selectClient
                } label: {
                    Label {
                        Text("ajouter un client")
                            .tint(.primary)
                    } icon: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.white, .green)
                    }
                }
                
                if !clients.isEmpty {
                    List {
                        ForEach(clients) { client in
                            ClientRowView(
                                firstname: client.firstname ?? "Inconnu",
                                name: client.name ?? ""
                            )
                        }
                        .onDelete(perform: { indexSet in
                            clients.remove(atOffsets: indexSet)
                        })
                    }
                }
                
            } header: {
                Text("Client(s) séléctionné(s)")
            }
            
            // MARK: - Partie type Acte
            Section {
                Button {
                    activeSheet = .selectTypeActe
                } label: {
                    Label {
                        Text("ajouter un type d'acte")
                            .tint(.primary)
                    } icon: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.white, .green)
                    }
                }
                
                if !listTypeActes.isEmpty {
                    List {
                        ForEach(listTypeActes.indices, id: \.self) { index in
                            TypeActeRowView(
                                text: listTypeActes[index].typeActeReal.name ?? "Inconnu",
                                price: String(format: "Prix total : %.2f €", listTypeActes[index].typeActeReal.total),
                                ttl: $listTypeActes[index]
                            )
                        }
                        .onDelete(perform: { indexSet in
                            listTypeActes.remove(atOffsets: indexSet)
                        })
                    }
                }
            } header : {
                Text("Type d'acte séléctionné(s)")
            } footer : {
                Text("Pour supprimer un élément de la liste, déplacé le sur la gauche.")
            }
            
            if typeSelected == .facture {
                Section("Réglement") {
                    Toggle("Facture déjà réglée ?", isOn: $estPayer.animation())
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    if estPayer {
                        Picker("Mode de paiement", selection: $selectedPayement){
                            ForEach(Payement.allCases) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                    }
                }
            }
            
            Section("Note - optionnel") {
                TextEditor(text: $notes)
                    .lineSpacing(2)
            }
        }
        .navigationTitle("\(typeSelected.rawValue.capitalized) #\(numero)")
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button {
                    
                } label: {
                    Label("Sauvegarder", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
                
                Button {
                    activeSheet = .apercusDocument(facture : exempleFacture)
                } label: {
                    Label("Aperçus", systemImage: "eyeglasses")
                }
                .buttonStyle(.bordered)
                
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.regularMaterial)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Options") {
                    DetailFormView()
                }
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .apercusDocument(facture : let facture):
                DisplayPDFView(facture: facture)
                    .presentationDetents([.large])
            case .selectClient:
                ListClients(callbackClientClick: { client in
                    clients.append(client)
                })
            case .selectTypeActe:
                ListTypeActe(callbackClick: { type in
                    listTypeActes.append(TTLTypeActe(typeActeReal: type, quantity: 1))
                })
            default:
                EmptyView() // IMPOSSIBLE
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        clients.remove(atOffsets: offsets)
    }
    
    func save() {
        
    }
}

private struct ClientRowView: View {
    let firstname : String
    let name : String
    
    var body: some View {
        HStack {
            ProfilImageView(imageData: nil)
            
            VStack {
                Text(firstname)
                + Text(" ")
                + Text(name)
                    .bold()
            }
        }
    }
}

private struct TypeActeRowView: View {
    let text : String
    let price : String
    @Binding var ttl : TTLTypeActe
    
    var body: some View {
        HStack {
            Image(systemName: "cross.case.circle.fill")
                .imageScale(.large)
                .foregroundStyle(.white, .purple)
            
            VStack(alignment: .leading) {
                Text(text)
                    .font(.body)
                    .tint(.primary)
                
                Text(price)
                    .font(.caption)
                    .tint(.secondary)
            }
            
            Picker("", selection: $ttl.quantity) {
                ForEach(1...100, id: \.self) { number in
                    Text("\(number)")
                }
            }
        }
    }
}

struct TTLTypeActe : Identifiable {
    var id : UUID = UUID()
    var typeActeReal: TypeActe
    var quantity : Int
}

#Preview {
    FormDocumentView()
}
