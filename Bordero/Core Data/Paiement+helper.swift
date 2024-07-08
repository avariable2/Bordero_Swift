//
//  Paiement+helper.swift
//  Bordero
//
//  Created by Grande Variable on 12/05/2024.
//

import Foundation
import CoreData

extension Paiement {
    
    var date : Date {
        get { date_ ?? Date() }
        set { date_ = newValue }
    }
    
    convenience init(montant : Double, date: Date, context : NSManagedObjectContext) {
        self.init(context: context)
        self.montant = montant
        self.date = date
    }
    
    public override func awakeFromInsert() {
        self.id = UUID()
    }
    
    public static func fetch() -> NSFetchRequest<Paiement> {
        let request = Paiement.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Paiement.date_, ascending: true)]
//        request.predicate = predicate
        
        return request
    }
    
    static var example : Paiement {
        return Paiement(montant: 50, date: Date(), context: DataController.shared.container.viewContext)
    }
    
    static var example2 : Paiement {
        var component      = DateComponents()
        component.calendar = Calendar.current
        component.year     = 2016
        component.month    = 2
        component.day      = 28
        return Paiement(montant: 40, date: component.date ?? Date(), context: DataController.shared.container.viewContext)
    }
}
