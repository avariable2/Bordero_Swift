//
//  Document+helper.swift
//  Bordero
//
//  Created by Grande Variable on 19/04/2024.
//

import Foundation
import SwiftUI
import CoreData

extension Document {
    struct SnapshotClient {
        var lastname : String
        var firstname : String
        var phone : String
        var email : String
        var code_entreprise : String
        var adresse : String
        var uuidClient : UUID?
    }
    
    struct SnapshotPraticien {
        var lastname : String
        var firstname : String
        var phone : String
        var email : String
        var website : String
        var adresse : String
        var siret : String
        var adeli : String
        var signature : Data?
        var logo : Data?
    }
    
    struct Remise {
        var type : String
        var montant : Double
    }
    
    struct PayementAllow {
        var carte : Bool
        var cheque : Bool
        var virement : Bool
        var especes : Bool
        
        func enabledPaymentsString() -> [String] {
            var payments: [String] = []
            if carte {
                payments.append("Carte bancaire")
            }
            if cheque {
                payments.append("Chèque")
            }
            if virement {
                payments.append("Virement bancaire")
            }
            if especes {
                payments.append("Espèces")
            }
            return payments
        }

    }
    
    enum Status : String, Identifiable, CaseIterable {
        case all = "Tous"
        case created = "Crée"
        case payed = "Payée"
        case send = "Envoyée"
        
        var id: String { rawValue }
        
        case unknow = "Inconnu"
    }
    
    var numero : String {
        get { numeroDocument_ ?? "" }
        set { numeroDocument_ = newValue }
    }
    
    var status : Status {
        get {
            switch status_ {
            case 0: .created
            case 1: .payed
            case 2: .send
            default: .unknow
            }
        }
        set {
            status_ = switch newValue {
            case .created: 0
            case .payed: 1
            case .send : 2
            default : 3
            }
        }
    }
    
    var note : String {
        get { note_ ?? "" }
        set { note_ = newValue }
    }
    
    var payementUse : String {
        get { payementUse_ ?? "" }
        set { payementUse_ = newValue }
    }
    
    var dateEcheance : Date {
        get { dateEcheance_ ?? Date() }
        set { dateEcheance_ = newValue }
    }
    
    var sectionTitleByDate : String {
        get { titleForDate(dateEmission) }
    }
    
    var dateEmission : Date {
        get { dateEmission_ ?? Date() }
        set { dateEmission_ = newValue }
    }
    
    var estDeTypeFacture : Bool {
        get { estFacture_ }
        set {
            estFacture_ = newValue
        }
    }
    
    var totalHT : Double {
        get { totalHT_ }
        set { totalHT_ = newValue }
    }
    
    var totalTVA : Double {
        get { totalTVA_ }
        set { totalTVA_ = newValue }
    }
    
    var totalTTC : Double {
        get { totalTTC_ }
        set { totalTTC_ = newValue }
    }
    
    var snapshotClient : SnapshotClient {
        get {
            SnapshotClient(
                lastname: snapshotClient_?["lastname"] as? String ?? "",
                firstname: snapshotClient_?["firstname"] as? String ?? "",
                phone: snapshotClient_?["phone"] as? String ?? "",
                email: snapshotClient_?["email"] as? String ?? "",
                code_entreprise: snapshotClient_?["code_entreprise"] as? String ?? "",
                adresse: snapshotClient_?["adresse"] as? String ?? "",
                uuidClient: snapshotClient_?["uuidClient"] as? UUID
            )
        }
        set {
            snapshotClient_ = [
                "lastname" : newValue.lastname,
                "firstname" : newValue.firstname,
                "phone" : newValue.phone,
                "email" : newValue.email,
                "code_entreprise" : newValue.code_entreprise,
                "adresse" : newValue.adresse,
                "uuidClient" : newValue.uuidClient?.uuidString ?? "",
            ]
        }
    }
    
    var snapshotPraticien : SnapshotPraticien {
        get {
            SnapshotPraticien(
                lastname: snapshotClient_?["lastname"] as? String ?? "",
                firstname: snapshotClient_?["firstname"] as? String ?? "",
                phone: snapshotClient_?["phone"] as? String ?? "",
                email: snapshotClient_?["email"] as? String ?? "",
                website: snapshotClient_?["website"] as? String ?? "",
                adresse: snapshotClient_?["adresse"] as? String ?? "",
                siret: snapshotClient_?["siret"] as? String ?? "",
                adeli: snapshotClient_?["adeli"] as? String ?? "",
                signature: snapshotClient_?["signature"] as? Data,
                logo: snapshotClient_?["logo"] as? Data
            )
        }
        set {
            snapshotPraticien_ = [
                "lastname" : newValue.lastname,
                "firstname" : newValue.firstname,
                "phone" : newValue.phone,
                "email" : newValue.email,
                "website" : newValue.website,
                "adresse" : newValue.adresse,
                "siret" : newValue.siret,
                "adeli" : newValue.adeli,
                "signature" : newValue.signature as Any ,
                "logo" : newValue.logo as Any
            ]
        }
    }
    
    var remise : Remise {
        get {
            Remise(
                type: remise_?["type"] as? String ?? "",
                montant: remise_?["montant"] as? Double ?? 0
            )
        }
        set {
            remise_ = [
                "type" : newValue.type,
                "montant" : newValue.montant
            ]
        }
    }
    
    var payementAllow : PayementAllow {
        get {
            PayementAllow(
                carte: payementAllow_?["carte"] as? Bool ?? true,
                cheque: payementAllow_?["cheque"] as? Bool ?? true,
                virement: payementAllow_?["virement"] as? Bool ?? true,
                especes: payementAllow_?["especes"] as? Bool ?? true
            )
        }
        set {
            payementAllow_ = [
                "carte": newValue.carte,
                "cheque": newValue.cheque,
                "virement": newValue.virement,
                "especes": newValue.especes
            ]
        }
    }
    
    var listSnapshotTypeActe: Set<SnapshotTypeActe> {
        get { self.elements as? Set<SnapshotTypeActe> ?? [] }
        set { self.elements = newValue as NSSet }
    }

    
    var payementFinish : Bool {
        get { payementFinish_ }
        set { payementFinish_ = newValue }
    }
    
    var listOfHistorique : Set<HistoriqueEvenement> {
        get {
            historique as! Set<HistoriqueEvenement>
        }
    }
    
    var listOfTypeActe : Set<SnapshotTypeActe> {
        get {
            elements as! Set<SnapshotTypeActe>
        }
    }
    
    var montantPayer : Double {
        get { montantPayer_ }
        set { montantPayer_ = newValue }
    }
    
    func titleForDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Aujourd'hui"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Hier"
        } else if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            return "Cette semaine"
        } else if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month) {
            return "Ce mois"
        } else if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
            return "Cette année"
        } else {
            return "Années précédentes"
        }
    }
    
    func determineStatut() -> String {
        return switch self.status {
        case .created: "Ouvert"
        case .payed: "Payer"
        case .send: "Envoyée"
        default: "Inconnu"
        }
    }
    
    func determineColor() -> Color {
        return switch self.status {
        case .created: .orange
        case .payed: .green
        case .send: .blue
        default: .brown
        }
    }
    
    func getNameOfDocument() -> String {
//        return "\(self.snapshotClient.firstname) \(self.snapshotClient.lastname) \(self.estDeTypeFacture ? "Facture" : "Devis")"
        return "\(client_?.firstname ?? "") \(client_?.lastname ?? "") \(self.estDeTypeFacture ? "Facture" : "Devis")"
    }
    
    static func delete(document: Document) {
        guard let context = document.managedObjectContext else { return }
        
        context.delete(document)
    }
    
    static func fetch(_ predicate: NSPredicate = .all) -> NSFetchRequest<Document> {
        let request = Document.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Document.dateEmission_, ascending: true)]
        request.predicate = predicate
        
        return request
    }
    
    static var example: Document {
        let context = DataController.shared.container.viewContext
        let document = Document(context: context)
        
        return document
    }

}
