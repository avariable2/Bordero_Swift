//
//  PDFDatat.swift
//  Bordero
//
//  Created by Grande Variable on 25/03/2024.
//

import Foundation

struct Facture {
    struct Praticien {
        var numeroDelit: String?
        var numeroSIREP: String?
        var nom: String?
        var adresse: String?
        var telephone: String?
        var email: String?
    }
    
    struct Utilisateur {
        var nom: String
        var adresse: String
        // Ajoutez d'autres champs nécessaires
    }
    
    struct ElementFacture {
        var description: String
        var quantite: Int
        var prixUnitaire: Double
        var prixTotal: Double {
            Double(quantite) * prixUnitaire
        }
    }
    
    enum TypeDocument {
        case facture, devis
    }
    
    var praticien: Praticien
    var utilisateurs: [Utilisateur]
    var typeDocument: TypeDocument
    var numeroDocument: String
    var elements: [ElementFacture]
    var signature: Bool // true pour facture, false pour devis
}

// Exemple de données
let exempleFacture = Facture(
    praticien: Facture.Praticien(
        numeroDelit: "12345",
        numeroSIREP: "67890",
        nom: "Dr. Exemple",
        adresse: "123 Rue Exemple, Exempleville",
        telephone: "0102030405",
        email: "dr.exemple@example.com"
    ),
    utilisateurs: [
        Facture.Utilisateur(nom: "Jean Dupont", adresse: "456 Rue Autre, Autreville")
    ],
    typeDocument: .facture,
    numeroDocument: "FAC-001",
    elements: [
        Facture.ElementFacture(description: "Consultation", quantite: 1, prixUnitaire: 50.0),
        Facture.ElementFacture(description: "Radiographie", quantite: 2, prixUnitaire: 30.0)
    ],
    signature: true
)
