//
//  PraticienController.swift
//  Bordero
//
//  Created by Grande Variable on 26/02/2024.
//

import Foundation
import CoreData

protocol Saveable {
    func save()
}

protocol Modifyable {
    func modify()
}

// Protocol utile pour permettre de modifier les entités dans CloudKit sans que cela affecte les anciennes version de l'application qui récupéreront
// leur version actuel et permettre de recuperer les anciennes.
protocol Versionnable {
    func getVersion() -> Int32
}
