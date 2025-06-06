//
//  ActiveSheet.swift
//  Bordero
//
//  Created by Grande Variable on 05/02/2024.
//

import Foundation

enum ActiveSheet : Identifiable {
    case createTypeActe, editTypeActe(type : TypeActe)
    case createClient, editClient(client: Client)
    case profil(user : Praticien?)
    case parameters
    case optionsDocument, apercusDocument, selectClient, selectTypeActe
    case showAllHistoriquePaiement, showDetailPaiement(paiement : Paiement)
    
    var id : Int {
        switch self {
        case .createTypeActe:
            return 0
            
        case .editTypeActe(type: let type):
            return type.hashValue
            
        case .createClient :
            return 1
            
        case .editClient(client: let client):
            return client.hashValue
            
        case .profil(user: _):
            return 2
            
        case .parameters:
            return 3
            
        case .optionsDocument:
            return 4
            
        case .apercusDocument:
            return 7
            
        case .selectClient:
            return 5
            
        case .selectTypeActe:
            return 6
            
        case .showAllHistoriquePaiement:
            return 7
            
        case .showDetailPaiement(paiement: let paiement):
            return paiement.hashValue
        }
    }
}
