//
//  PDFDatat.swift
//  Bordero
//
//  Created by Grande Variable on 25/03/2024.
//

import Foundation

struct DocumentData {
    typealias TableElement = (Int, TypeActe)
    
    struct OptionsLegalDocument {
        var typeDocument : TypeDoc
        var payementAllow : [Payement]
        var payementFinish : Bool
        var payementUse : Payement?
        var dateCreated : Date
        var dateEcheance : Date
        var remise : Int?
    }
    
    var praticien: Praticien
    var clients: [Client]
    var elements: [TableElement]
    var optionsDocument : OptionsLegalDocument
}

// Exemple de données
//let exempleFacture = DocumentData(
//    praticien: DocumentData.Praticien(
//        numeroDelit: "12345",
//        numeroSIREP: "67890",
//        nom: "Dr. Exemple",
//        adresse: "123 Rue Exemple, Exempleville",
//        telephone: "0102030405",
//        email: "dr.exemple@example.com",
//        website: "dr.example.com"
//    ),
//    utilisateurs: [
//        DocumentData.Utilisateur(nom: "Jean Dupont", adresse: "456 Rue Autre, Autreville")
//    ],
//    typeDocument: .facture,
//    numeroDocument: "FAC-001",
//    elements: [
//        DocumentData.ElementFacture(description: "Consultation", quantite: 1, prixUnitaire: 50.0),
//        DocumentData.ElementFacture(description: "Radiographie", quantite: 2, prixUnitaire: 30.0)
//    ],
//    signature: true
//)

let fakePraticien = Praticien(firstname: "Adrien", lastname: "VARY", phone: "07 67 91 90 44", email: "email.vary@gmail.com", website: "", siret: "0245654", adeli: "021547896321", context: DataController.shared.container.viewContext)

let client = Client(firstname: "Pierre", lastname: "Je commence", phone: "", email: "", context: DataController.shared.container.viewContext)

let typeActe = TypeActe(name: "Séance bi", price: 50, tva: 0, context: DataController.shared.container.viewContext)

let exempleFacture = DocumentData(
    praticien: fakePraticien,
    clients: [client],
    elements: [DocumentData.TableElement(1, typeActe), DocumentData.TableElement(1, typeActe)],
    optionsDocument: DocumentData.OptionsLegalDocument(
        typeDocument: .facture,
        payementAllow: [Payement.carte,Payement.cheque,],
        payementFinish: false,
        dateCreated: Date(),
        dateEcheance: Date()
    )
)
