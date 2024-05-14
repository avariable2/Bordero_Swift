//
//  ClientDetailView.swift
//  Bordero
//
//  Created by Grande Variable on 24/03/2024.
//

import SwiftUI

struct ClientDetailView: View {
    @Environment(\.dismiss) private var dismiss
//    @Environment(NavigationDestinationClient.self) var path
    
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
        Form {
            ClientDetailHeaderView(client: client)
            
            Section("Données sur le mois en cours") {
                GraphPiView(client: client, temporalite: .constant(.mois))
                
                NavigationLink {
                    ClientDataView(client: client)
                } label: {
                    Text("Voir plus de statistiques")
                        .foregroundStyle(.link)
                        .padding([.top, .bottom], 6)
                }
            }
            
            Section {
                DisclosureGroup(isExpanded: $topExpanded) {
                    if listDocumentsToShow.isEmpty {
                        ContentUnavailableView(
                            "Aucun document",
                            systemImage: "tray"
                        )
                    } else {
                        List(listDocumentsToShow) { document in
                            RowDocumentView(document: document)
                        }
                    }
                } label: {
                    Text("Historique")
                        .bold()
                }
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
        
        
        listDocumentsToShow = Array(client.listDocuments)
        listDocumentsToShow.sort { doc1, doc2 in
            doc1.dateEmission > doc2.dateEmission // trie du plus récent au plus vieux
        }
    }
    
    func getNumberOfDocumentWaiting(_ listDocuments : Set<Document>) -> Int {
        
        return listDocuments.filter { $0.status == .send && $0.payementFinish == false }.count
    }
    
    func getNumberOfDocumentPayed(_ listDocuments : Set<Document>) -> Int {
        
        return listDocuments.filter { $0.status == .payed }.count
    }
    
    /**
    Affiche le montant total de toutes les documents envoyés et dont le payement n'est pas fini en euros. 
     */
    func getAmountWaiting(_ listDocuments : Set<Document>) -> Double {
        let documentsWaiting = listDocuments.filter {  $0.status == .send && $0.payementFinish == false }
        
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
    
    func getDocuments() -> Array<Document> {
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
            DisclosureGroup(isExpanded: $showAdresses) {
                if let coordonne1 = client.adresse1, !coordonne1.isEmpty {
                    RowAdresse(adresseSurUneLigne: client.getAdresseSurUneLigne(coordonne1))
                }
                if let coordonne2 = client.adresse2, !coordonne2.isEmpty {
                    RowAdresse(adresseSurUneLigne: client.getAdresseSurUneLigne(coordonne2))
                }
                if let coordonne3 = client.adresse3, !coordonne3.isEmpty {
                    RowAdresse(adresseSurUneLigne: client.getAdresseSurUneLigne(coordonne3))
                }
                
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
            } label: {
                HStack {
                    ProfilImageView(imageData: nil)
                        .font(.title)
                    
                    Text("\(client.firstname) \(client.lastname)")
                        .font(.title2)
                        .bold()
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

#Preview {
    ClientDetailView(client: Client.example)
}
