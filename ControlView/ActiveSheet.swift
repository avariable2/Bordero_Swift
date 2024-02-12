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
        }
    }
}
