//
//  PDFDatat.swift
//  Bordero
//
//  Created by Grande Variable on 25/03/2024.
//

import Foundation
import CoreData

struct PDFModel {
    
    struct OptionsLegalDocument {
        var typeDocument : TypeDoc
        var numeroDocument: String
        var payementAllow : [Payement]
        var payementFinish : Bool
        var payementUse : Payement
        var dateCreated : Date
        var afficherDateEcheance : Bool = true
        var dateEcheance : Date
        var remise : Int?
    }
    
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
            dateCreated: Date(),
            dateEcheance: Date()
        )
        self.praticien = nil
        self.elements = []
        self.client = nil
    }
    
}

