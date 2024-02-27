//
//  PraticienController.swift
//  Bordero
//
//  Created by Grande Variable on 26/02/2024.
//

import Foundation
import CoreData
import SwiftUI
import Observation

protocol Saveable {
    func save()
}

protocol Modifyable {
    func modify()
}

// Protocol utile pour permettre de modifier les entités dans CloudKit sans que cela affecte les anciennes version de l'application qui récupéreront
// leur version actuel et permettre de recuperer les anciennes.
protocol Versionnable {
    static func getVersion() -> Int32
}

@Observable
class PraticienUtils {
    
    static let shared = PraticienUtils()
    
    static let predicate = NSPredicate(
        format: "version <= %d && id == %@",
        argumentArray: [FormPraticienView.getVersion(), FormPraticienView.uuidPraticien! as CVarArg]
    )
}
