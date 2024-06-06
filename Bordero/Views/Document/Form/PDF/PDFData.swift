//
//  PDFDatat.swift
//  Bordero
//
//  Created by Grande Variable on 25/03/2024.
//

import Foundation

struct PDFModel {    
    struct OptionsLegalDocument : Codable {
        var estFacture : Bool
        var numeroDocument: String
        var payementAllow : [Payement]
        var payementFinish : Bool
        var payementUse : Payement
        var dateEmission : Date
        var afficherDateEcheance : Bool = true
        var dateEcheance : Date
        var remise : Remise
        var note : String
    }
    
    var historique : [Evenement]
    var praticien: Praticien?
    var client: Client?
    var elements: [SnapshotTypeActe]
    var optionsDocument : OptionsLegalDocument
    
    var urlFilePreview : URL? = nil
    
    var totalTTC = 0
    var totalTVA = 0
    var totalHT = 0
    
    init() {
        self.optionsDocument = OptionsLegalDocument(
            estFacture: true,
            numeroDocument: "",
            payementAllow: [],
            payementFinish: false,
            payementUse: .carte,
            dateEmission: Date(),
            dateEcheance: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(), // Ajoute par defaut 30 jours
            remise: Remise(type: .pourcentage, montant: 0),
            note: ""
        )
        self.historique = [Evenement(nom: .création, date: Date()),]
        self.praticien = nil
        self.elements = []
        self.client = nil
    }
    
    func calcTotalTTC() -> Double {
        return calcTotalHT() + calcTotalTVA()
    }
    
    func calcTotalHT() -> Double  {
        var sousTot : Double = 0
        for element in elements {
            sousTot += Double(element.price) * Double(element.quantity)
        }
        
        if self.optionsDocument.remise.montant != 0 {
            switch self.optionsDocument.remise.type {
            case .pourcentage:
                sousTot -= self.optionsDocument.remise.montant * sousTot
            case .montantFixe:
                sousTot -= self.optionsDocument.remise.montant
            }
        }
        
        return sousTot
    }
    
    func calcTotalTVA() -> Double {
        var montantTVA : Double = 0
        for element in elements {
            if element.tva != 0 {
                montantTVA += ((Double(element.price) * Double(element.tva)) + Double(element.price)) * Double(element.quantity)
            }
        }
        return montantTVA
    }
}

struct Evenement : Identifiable, Codable {
    enum TypeEvenement : String, CaseIterable, Identifiable, Codable {
        var id : Self { self }
        
        case création = "Création"
        case modification = "Modification"
        case envoie = "Envoi"
        case renvoie = "Renvoi"
        case payer = "Ajout d'un paiement"
        case exporté = "Exporté en PDF"
    }
    var id: UUID = UUID()
    
    var nom : TypeEvenement
    var date : Date
}

enum TypeDoc : String, CaseIterable, Identifiable, Codable {
    case facture, devis
    
    var id: Self { self }
}

enum Payement : String, CaseIterable, Identifiable, Codable {
    case carte = "Carte bancaire", especes = "Espèces", virement = "Virement bancaire", cheque = "Chèque"
    
    var id: Self { self }
    
    static func findPaymentType(from string: String) -> Payement? {
        return Payement.allCases.first(where: { $0.rawValue == string })
    }
}

struct Remise: Codable {
    enum TypeRemise: CaseIterable, Identifiable, CustomStringConvertible, Codable {
        case pourcentage
        case montantFixe
        
        var id: Self { self }
        var description: String {
            switch self {
            case .pourcentage:
                return "Pourcentage"
            case .montantFixe:
                return "Montant Fixe"
            }
        }
        
        static func findDiscountType(from description: String) -> TypeRemise? {
            return TypeRemise.allCases.first(where: { $0.description == description })
        }
    }
    
    var type : TypeRemise
    var montant : Double
}

struct TTLTypeActe : Identifiable, Equatable {
    var id : UUID = UUID()
    var snapshotTypeActe: SnapshotTypeActe
    var quantity : Double
    var date = Date()
    var remarque : String = ""
}
