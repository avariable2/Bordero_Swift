//
//  TypeActe+helper.swift
//  Bordero
//
//  Created by Grande Variable on 10/04/2024.
//

import Foundation
import CoreData

extension TypeActe {
    
    var name : String {
        get { name_ ?? "" }
        set { name_ = newValue }
    }
    
    var info : String {
        get { info_ ?? "" }
        set { info_ = newValue }
    }
    
    var price : Double {
        get { price_ }
        set { price_ = newValue }
    }
    
    var tva : Double {
        get { tva_ }
        set { tva_ = newValue }
    }
    
    var total : Double {
        get { total_ }
        set { total_ = newValue }
    }
    
    /**
     Fonction qui à pour objectif de creer une copie du type d'acte pour etre sauvegarder en l'etat et évité que celui ci puisse etre modifier dans le future.
     Il prend un document en cours de création dans ces parametres pour l'affecté au champ **estUnElementDe**.
     - Parameters:
        - date: la date à laquel le type d'acte à été fait
        - quantite: le nombre de fois que ce type d'acte à été fait
     
     - Returns: Un snapshot (une copie gelée) du type d'acte
     */
    func getSnapshot(_ document : Document? = nil, date : Date, quantite: Double, remarque : String) -> SnapshotTypeActe {
        let snapshot = SnapshotTypeActe(context: DataController.shared.container.viewContext)
        
        snapshot.id = UUID()
        snapshot.uuidTypeActe = self.id
        if let doc = document {
            snapshot.estUnElementDe = doc
        }
        
        snapshot.name_ = self.name
        snapshot.info_ = self.info
        snapshot.price_ = self.price
        snapshot.tva_ = self.tva
        snapshot.total_ = self.total
        snapshot.date = date
        snapshot.quantity = quantite
        snapshot.remarque = remarque
        
        return snapshot
    }
    
    convenience init(
        name : String,
        info : String = "",
        price : Double,
        tva : Double,
        duree: Int64 = 60*60,
        context : NSManagedObjectContext) {
            self.init(context: context)
            self.id = UUID()
            self.name = name
            self.info = info
            self.price = price
            self.tva = tva
            self.duration_ = duree
            self.total = tva == 0 ? price : price * tva + price
    }
    
    func getWithDuration() -> TypeActeWithDuration {
        let timeComponents = Int(duration_).extractTimeComponents()
        let duration : Date
        if (timeComponents.hour != 0) && (timeComponents.minute != 0) {
            duration = Calendar.current.date(bySettingHour: timeComponents.hour, minute: timeComponents.minute, second: timeComponents.second, of: Date())!
        } else {
            duration = Calendar.current.date(bySettingHour: 1, minute: timeComponents.minute, second: timeComponents.second, of: Date())!
        }
        
        let typeActeWithDuration = TypeActeWithDuration(
            typeActe: self,
            duration: duration
        )
        return typeActeWithDuration
    }
}
