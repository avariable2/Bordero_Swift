//
//  ClientDetailView.swift
//  Bordero
//
//  Created by Grande Variable on 24/03/2024.
//

import SwiftUI

struct ClientDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationDestinationClient.self) var path
    
    @State private var activeSheet: ActiveSheet?
    @ObservedObject var client : Client
    
    @State private var numberOfDocumentWaiting : Int = 0
    @State private var numberOfDocumentPayed : Int = 0
    @State private var amountPayed : Double = 0
    @State private var amountWaiting : Double = 0
    @State private var numberOfDocumentThisMonth : Int = 0
    
    @State private var listDocumentsToShow : Array<Document> = []
    
    @State private var topExpanded: Bool = true
    
    var body: some View {
        List {
            ClientDetailHeaderView(client: client)
            
            Section {
                RowIconColor(
                    text: client.email.isEmpty ? "Aucun e-mail renseigné" : client.email,
                    systemName: "envelope.circle.fill",
                    color: .blue,
                    accessibility: "L'e-mail du client"
                )
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = client.email
                    }) {
                        Text("Copier")
                        Image(systemName: "doc.on.doc")
                    }
                }
                
                RowIconColor(
                    text: client.phone.isEmpty ? "Aucun téléphone renseigné" : client.phone,
                    systemName: "phone.circle.fill",
                    color: .green,
                    accessibility: "Le numéro de téléphone du client"
                )
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = client.phone
                    }) {
                        Text("Copier")
                        Image(systemName: "doc.on.doc")
                    }
                }
            }
            
            Section("Données sur le mois en cours") {
                GroupBox {
                    DataValueView(
                        value: amountWaiting.description,
                        unit: "€ sur \(numberOfDocumentWaiting) document(s) envoyer"
                    )
                } label: {
                    Label("Montant en attente", systemImage: "bag.fill.badge.questionmark")
                }
                .groupBoxStyle(
                    GroupBoxStyleData(
                        color: .pink,
                        destination: Text("Oui")
                    )
                )
                
                GroupBox {
                    DataValueView(
                        value: amountPayed.description,
                        unit: "€ sur \(numberOfDocumentPayed) documents payer"
                    )
                } label: {
                    Label("Total payé par le client", systemImage: "bag.fill.badge.plus")
                }
                .groupBoxStyle(GroupBoxStyleData(color: .indigo, destination: Text("Oui")))
                
                GroupBox {
                    DataValueView(value: numberOfDocumentThisMonth.description, unit: "document(s)")
                } label: {
                    Label("Document(s) créer", systemImage: "folder.fill")
                }
                .groupBoxStyle(GroupBoxStyleData(color: .orange, destination: Text("Oui")))
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 20))
            
            Section {
                DisclosureGroup(isExpanded: $topExpanded) {
                    if listDocumentsToShow.isEmpty {
                        Text("Aucun document")
                    } else {
                        ForEach(listDocumentsToShow) { document in
                            RowDocumentView(document: document)
                        }
                    }
                } label: {
                    Text("Historique")
                        .bold()
                }
            } header : {
                
            } footer : {
                Text("Affiche uniquement les 20 dernières documents crées.\n")
                + Text("Veuillez consulter la section ")
                + Text("\"Liste des docs\"")
                    .foregroundStyle(.green)
                    .bold()
                + Text(" pour accèder à des documents plus ancien.")
            }
            
        }
        .navigationTitle("Fiche client")
        .headerProminence(.increased)
        .onAppear() {
            getDataFormClient()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Modifier") {
                    activeSheet = .editClient(client: client)
                }
                .buttonStyle(.bordered)
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .editClient(let client):
                FormClientSheet(onCancel: {
                    activeSheet = nil
                }, onSave: {
                    activeSheet = nil
                }, clientToModify: client) {
                    dismiss()
                }
                .presentationDetents([.large])
            default:
                EmptyView() // IMPOSSIBLE
            }
        }
    }
    
    func getDataFormClient() {
        let listDocuments = client.listDocuments.filter { $0.dateEmission.formatted(.dateTime.month()) == Date().formatted(.dateTime.month()) }
        
        numberOfDocumentWaiting = getNumberOfDocumentWaiting(listDocuments)
        amountWaiting = getAmountWaiting(listDocuments)
        
        numberOfDocumentPayed = getNumberOfDocumentPayed(listDocuments)
        amountPayed = getAmountPayed(listDocuments)
        
        numberOfDocumentThisMonth = getNumberOfDocumentThisMonth(listDocuments)
        
        listDocumentsToShow = get20LastDocuments()
    }
    
    func getNumberOfDocumentWaiting(_ listDocuments : Set<Document>) -> Int {
        
        return listDocuments.filter { $0.status == .send && $0.payementFinish == false }.count
    }
    
    func getNumberOfDocumentPayed(_ listDocuments : Set<Document>) -> Int {
        
        return listDocuments.filter { $0.status == .payed }.count
    }
    
    func getAmountWaiting(_ listDocuments : Set<Document>) -> Double {
        let documentsWaiting = listDocuments.filter {  $0.status == .created && $0.payementFinish == false }
        
        var amountWaiting : Double = 0
        for documentWaiting in documentsWaiting {
            amountWaiting += documentWaiting.totalTTC
        }
        return amountWaiting
    }
    
    func getAmountPayed(_ listDocuments : Set<Document>) -> Double {
        let documentsPayed = listDocuments.filter { $0.status == .payed }
        
        var amountPayed : Double = 0
        for documentsPay in documentsPayed {
            amountPayed += documentsPay.totalTTC
        }
        return amountPayed
    }
    
    func getNumberOfDocumentThisMonth(_ listDocuments : Set<Document>) -> Int {
        
        return listDocuments.count
    }
    
    func get20LastDocuments() -> Array<Document> {
        let tabDocuments = Array(client.listDocuments.suffix(20))
        
        let sortedDocuments = tabDocuments.sorted { $0.dateEmission > $1.dateEmission }
        
        let tabFinal = Array(sortedDocuments.prefix(20))
        return tabFinal
    }
}

struct ClientDetailHeaderView: View {
    
    @ObservedObject var client : Client
    @State private var showAdresses = false
    
    var body: some View {
        Section {
            ViewThatFits {
                HStack {
                    ProfilImageView(imageData: nil)
                        .font(.title)
                    
                    Text("\(client.firstname) \(client.lastname)")
                        .font(.title2)
                        .bold()
                    
                    Spacer()
                    
                    Image(systemName: showAdresses ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
                
                VStack {
                    HStack {
                        ProfilImageView(imageData: nil)
                            .font(.title)
                        
                        Text(client.firstname)
                            .font(.title3)
                            .bold()
                        
                        Text(client.lastname)
                            .font(.title3)
                            .bold()
                        
                    }
                    Image(systemName: showAdresses ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
                
                VStack {
                    HStack {
                        ProfilImageView(imageData: nil)
                            .font(.title)
                        Spacer()
                        VStack {
                            Text(client.firstname)
                                .fixedSize()
                                .font(.title3)
                                .bold()
                            
                            Text(client.lastname)
                                .font(.title3)
                                .bold()
                        }
                        .multilineTextAlignment(.center)
                        
                        
                    }
                    
                    Image(systemName: showAdresses ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                        .padding(.top)
                }
            }
            
            if showAdresses {
                
                if let coordonne1 = client.adresse1, !coordonne1.isEmpty {
                    RowAdresse(adresseSurUneLigne: client.getAdresseSurUneLigne(coordonne1))
                }
                if let coordonne2 = client.adresse2, !coordonne2.isEmpty {
                    RowAdresse(adresseSurUneLigne: client.getAdresseSurUneLigne(coordonne2))
                }
                if let coordonne3 = client.adresse3, !coordonne3.isEmpty {
                    RowAdresse(adresseSurUneLigne: client.getAdresseSurUneLigne(coordonne3))
                }
            }
        }
        .onTapGesture {
            withAnimation {
                showAdresses.toggle()
            }
        }
    }
}

struct RowAdresse: View {
    
    let adresseSurUneLigne : String
    
    var body: some View {
        RowIconColor(
            text: adresseSurUneLigne,
            systemName: "house.circle.fill",
            color: .brown,
            accessibility: "Adresse renseigné pour le client"
        )
        .contextMenu {
            Button(action: {
                UIPasteboard.general.string = adresseSurUneLigne
            }) {
                Text("Copier")
                Image(systemName: "doc.on.doc")
            }
        }
    }
}

//#Preview {
//    ClientDetailView(client: Client(firstname: "Adriennne", lastname: "VARY", phone: "0102030405", email: "exemple.vi@gmail.com", context: DataController.shared.container.viewContext))
//}
