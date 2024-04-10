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
    
    convenience init(
        name : String,
        info : String = "",
        price : Double,
        tva : Double,
        context : NSManagedObjectContext) {
            self.init(context: context)
            self.name = name
            self.info = info
            self.price = price
            self.tva = tva
            self.total = tva == 0 ? price : price * tva + price
    }
    
}
