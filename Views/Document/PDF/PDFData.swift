//
//  PDFDatat.swift
//  Bordero
//
//  Created by Grande Variable on 25/03/2024.
//

import Foundation
import CoreData

struct PDFModel /*: Identifiable, Equatable*/ {
//    var id: UUID = UUID()
//    
//    static func == (lhs: PDFModel, rhs: PDFModel) -> Bool {
//        lhs.id == rhs.id
//    }
    
    struct OptionsLegalDocument {
        var typeDocument : TypeDoc
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
    var elements: [TTLTypeActe]
    var optionsDocument : OptionsLegalDocument
    
    init() {
        self.optionsDocument = OptionsLegalDocument(
            typeDocument: .facture,
            numeroDocument: "",
            payementAllow: [],
            payementFinish: false,
            payementUse: .carte,
            dateEmission: Date(),
            dateEcheance: Calendar.current.date(byAdding: .day, value: 30, to: Date())!, // Ajoute par defaut 30 jours
            remise: Remise(type: .pourcentage, montant: 0),
            note: ""
        )
        self.historique = [Evenement(nom: .création, date: Date()),]
        self.praticien = nil
        self.elements = []
        self.client = nil
    }
}

struct Evenement : Identifiable {
    enum TypeEvenement : String, CaseIterable, Identifiable {
        var id : Self { self }
        
        case création = "Création"
        case modification = "Modification"
        case envoie = "Envoie"
        case renvoie = "Renvoie"
        case payer = "Payer"
    }
    var id: UUID = UUID()
    
    var nom : TypeEvenement
    var date : Date
}

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

struct Remise {
    enum TypeRemise: CaseIterable, Identifiable, CustomStringConvertible {
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
    }
    
    var type : TypeRemise
    var montant : Decimal
}

