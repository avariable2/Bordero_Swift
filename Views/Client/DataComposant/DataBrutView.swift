//
//  DataBrutView.swift
//  Bordero
//
//  Created by Grande Variable on 11/05/2024.
//

import SwiftUI

struct DataBrutView: View {
    @State var client : Client
    @Binding var temporalite : TempoChart
    
    @State var documentsEnAttente : Int = 0
    @State var nbrFacture : Int = 0
    @State var nbrDevis : Int = 0
    @State var acteFavoris : String = ""
    @State var derniersActesEffectuer : Array<String> = []
    
    @State var isLoading = false
    
    var vocabulaireTemporalité : String {
        switch temporalite {
        case .semaine:
            "la semaine"
        case .mois:
            "le mois"
        case .sixMois:
            "les 6 mois"
        case .annee:
            "l'année"
        }
    }
    
    var body: some View {
        Section {
            HStack {
                GroupBox {
                    DataValueView(value: documentsEnAttente.description, unit: "document(s)")
                } label: {
                    Label("En attentes", systemImage: "doc.badge.clock")
                }.groupBoxStyle(GroupBoxStyleDataWithoutDestination(color: .blue))
                
                GroupBox {
                    DataValueView(value: nbrFacture.description, unit: "sur \(vocabulaireTemporalité)")
                } label: {
                    Label("Nbr Facture", systemImage: "doc.richtext")
                }.groupBoxStyle(GroupBoxStyleDataWithoutDestination(color: .blue))
            }
            HStack {
                GroupBox {
                    DataValueView(value: nbrDevis.description, unit: "sur \(vocabulaireTemporalité)")
                } label: {
                    Label("Nbr Devis", systemImage: "doc.append")
                }.groupBoxStyle(GroupBoxStyleDataWithoutDestination(color: .blue))
                
                GroupBox {
                    DataValueView(value: nbrDevis.description, unit: "")
                } label: {
                    Label("Nbr docs / mois", systemImage: "heart")
                }.groupBoxStyle(GroupBoxStyleDataWithoutDestination(color: .blue))
            }
            
            GroupBox {
                DataValueView(value: acteFavoris.isEmpty ? "Aucun" : acteFavoris, unit: "sur \(vocabulaireTemporalité)")
            } label: {
                Label("Acte favoris", systemImage: "heart")
            }.groupBoxStyle(GroupBoxStyleDataWithoutDestination(color: .blue))
            
            GroupBox {
                DataValueView(value: derniersActesEffectuer.formatted(), unit: "sur \(vocabulaireTemporalité)")
            } label: {
                Label("Dernier acte effectuer", systemImage: "figure.walk")
            }.groupBoxStyle(GroupBoxStyleDataWithoutDestination(color: .blue))
        }
        .redacted(reason: isLoading ? .placeholder : [])
        .onAppear() {
            getData()
        }
        .onChange(of: temporalite) { oldValue, newValue in
            getData()
        }
    }
    
    func getData() {
        isLoading = true
        
        let list = getListByTempo()
        
        documentsEnAttente = getDocumentsEnAttentes(list)
        nbrFacture = getNbrFacture(list)
        nbrDevis = getNbrDevis(list)
        
        acteFavoris = getActeFavoris(list) ?? ""
        
        derniersActesEffectuer = getDernierActeEffectuer(list)
        
        isLoading = false
    }
    
    func getDocumentsEnAttentes(_ documents : Set<Document>) -> Int {
        let listDocsEnAttentes = documents.filter { $0.status == .send }
        return listDocsEnAttentes.count
    }
    
    func getNbrFacture(_ documents : Set<Document>) -> Int {
        let listDocsEnAttentes = documents.filter { $0.estDeTypeFacture }
        return listDocsEnAttentes.count
    }
    
    func getNbrDevis(_ documents : Set<Document>) -> Int {
        let listDocsEnAttentes = documents.filter { !$0.estDeTypeFacture }
        return listDocsEnAttentes.count
    }
    
    func getActeFavoris(_ documents : Set<Document>) ->  String? {
        var typeActeCount = [String: Int]() // Dictionnaire pour compter les occurrences des types d'acte
        
        for document in documents {
            // Parcourir tous les snapshotTypeActes dans chaque document
            for typeActe in document.listSnapshotTypeActe {
                // Compter chaque occurrence du type d'acte
                typeActeCount[typeActe.name, default: 0] += 1
            }
        }
        
        return typeActeCount.max(by: { $0.value < $1.value })?.key
    }
    
    func getDernierActeEffectuer(_ documents : Set<Document>) -> Array<String> {
        var list = Array(documents)
        list.sort { doc1, doc2 in
            doc1.dateEmission > doc2.dateEmission // trie du plus récent au plus vieux
        }
        
        var result : Array<String> = []
        if let listTravail = list.first {
            for typeActe in listTravail.listSnapshotTypeActe {
                result.append(typeActe.name)
            }
        }
        return result
    }
    
    func getListByTempo() -> Set<Document> {
        switch temporalite {
        case .semaine:
            return client.listDocuments.filter { doc in
                Calendar.current.isDate(doc.dateEmission, equalTo: Date(), toGranularity: .weekOfYear)
            }
        case .mois:
            return client.listDocuments.filter { doc in
                Calendar.current.isDate(doc.dateEmission, equalTo: Date(), toGranularity: .month)
            }
        case .sixMois:
            let range = ClientDataUtils.getSixMonthPeriodRange()
            return client.listDocuments.filter { doc in
                doc.dateEmission >= range.start && doc.dateEmission <= range.end
            }
        case .annee:
            return client.listDocuments.filter { doc in
                Calendar.current.isDate(doc.dateEmission, equalTo: Date(), toGranularity: .year)
            }
        }
    }
}

#Preview {
    DataBrutView(client: Client.example, temporalite: .constant(.mois))
}
