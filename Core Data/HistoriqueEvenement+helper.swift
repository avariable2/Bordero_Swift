//
//  HistoriqueEvenement+helper.swift
//  Bordero
//
//  Created by Grande Variable on 21/04/2024.
//

import Foundation
import SwiftUI

extension HistoriqueEvenement {
    var nom : String {
        get { nom_ ?? "" }
        set { nom_ = newValue }
    }
    
    var date : Date {
        get { date_ ?? Date() }
        set { date_ = newValue }
    }
}
