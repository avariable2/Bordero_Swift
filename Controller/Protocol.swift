//
//  PraticienController.swift
//  Bordero
//
//  Created by Grande Variable on 26/02/2024.
//

import Foundation
import CoreData
import SwiftUI

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
class UserUtils {
    
    var user : Praticien? = nil
    private var fetchRequest: NSFetchRequest<Praticien>
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.fetchRequest = Praticien.fetchRequest()
        self.fetchRequest.predicate = NSPredicate(
            format: "version <= %d",
            argumentArray: [FormPraticienView.getVersion()]
        )
        
        // Initialiser avec les données existantes
        fetchUser()
        
        // Observer les changements dans CoreData pour cet utilisateur
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: context)
    }
    
    @objc private func contextObjectsDidChange(_ notification: Notification) {
        fetchUser()
    }
        
    private func fetchUser() {
        do {
            let results = try context.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.user = results.first
            }
        } catch {
            print("Erreur lors de la récupération de l'utilisateur: \(error)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
