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
        var numeroDocument: String
        var payementAllow : [Payement]
        var payementFinish : Bool
        var payementUse : Payement?
        var dateCreated : Date
        var afficherDateEcheance : Bool = true
        var dateEcheance : Date
        var remise : Int?
    }
    
    var praticien: Praticien
    var clients: [Client]
    var elements: [TableElement]
    var optionsDocument : OptionsLegalDocument
}


let fakePraticien = Praticien(firstname: "Adrien", lastname: "VARY", phone: "07 67 91 90 44", email: "email.vary@gmail.com", website: "", siret: "0245654", adeli: "021547896321", context: DataController.shared.container.viewContext)

let client = Client(firstname: "Pierre-Louis-Adrien", lastname: "Je commence", phone: "000000", email: "email.vary@gmail.comemail.vary@gmail.comemail.vary@gmail.comemail.vary@gmail.comemail.vary@gmail.com", context: DataController.shared.container.viewContext)

let typeActe = TypeActe(name: "Séance bi", price: 50, tva: 0.20, context: DataController.shared.container.viewContext)

let exempleFacture = DocumentData(
    praticien: fakePraticien,
    clients: [client],
    elements: [DocumentData.TableElement(1, typeActe), DocumentData.TableElement(100, typeActe)],
    optionsDocument: DocumentData.OptionsLegalDocument(
        typeDocument: .facture,
        numeroDocument: "000111",
        payementAllow: [Payement.carte,Payement.cheque,],
        payementFinish: false,
        dateCreated: Date(),
        dateEcheance: Date()
    )
)
