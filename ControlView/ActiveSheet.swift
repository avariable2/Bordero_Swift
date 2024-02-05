//
//  ActiveSheet.swift
//  Bordero
//
//  Created by Grande Variable on 05/02/2024.
//

import Foundation

enum ActiveSheet : Identifiable {
    case createTypeActe, editTypeActe(type : TypeActe)
    
    case createClient
    
    var id : Int {
        switch self {
        case .createTypeActe:
            return 0
            
        case .editTypeActe(type: let type):
            return type.hash
            
        case .createClient :
            return Int.random(in: 1...1000000)
        }
    }
}
