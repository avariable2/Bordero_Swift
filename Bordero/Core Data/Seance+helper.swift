//
//  Seance+helper.swift
//  Bordero
//
//  Created by Grande Variable on 31/07/2024.
//

import Foundation
import CoreData

extension Seance {
    
    var dateDebut : Date {
        get {
            return startDate_ ?? Date()
        }
        set {
            startDate_ = newValue
        }
    }
    
//    var dateFin: Date {
//        get {
//            return endDate_ ?? Date()
//        }
//        set {
//            endDate_ = newValue
//        }
//    }
    
    var commentaire : String {
        get {
            return comment_ ?? ""
        }
        set {
            comment_ = newValue
        }
    }
    
    var titre : String {
        get {
            if let client_ {
                "Séance \(client_.fullname)"
            } else {
                "Inconnu"
            }
        }
    }
    
    public override func awakeFromInsert() {
        self.id = UUID()
    }
    
}
