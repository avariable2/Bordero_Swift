//
//  SnapshotTypeActe+helper.swift
//  Bordero
//
//  Created by Grande Variable on 19/04/2024.
//

import Foundation

extension SnapshotTypeActe {
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
    
    var date : Date {
        get { date_ ?? Date() }
        set { date_ = newValue }
    }
    
    var remarque : String {
        get { remarque_ ?? ""}
        set { remarque_ = newValue }
    }
}
