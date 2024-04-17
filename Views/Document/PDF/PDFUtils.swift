//
//  PDFUtils.swift
//  Bordero
//
//  Created by Grande Variable on 17/04/2024.
//

import Foundation

struct PDFUtils {
    
    static func getTableauInfoAdresse(_ coordonne : Adresse) -> [String] {
        var tab : [String] = []
        if let rue = coordonne.rue, !rue.isEmpty {
            tab.append(rue)
        }
        if let codepostal = coordonne.codepostal, !codepostal.isEmpty {
            tab.append(codepostal)
        }
        if let etageAppt = coordonne.etageAppt, !etageAppt.isEmpty {
            tab.append(etageAppt)
        }
        if let ville = coordonne.ville, !ville.isEmpty {
            tab.append(ville)
        }
        
        return tab
    }
}
