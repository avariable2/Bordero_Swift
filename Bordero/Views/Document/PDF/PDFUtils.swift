//
//  PDFUtils.swift
//  Bordero
//
//  Created by Grande Variable on 17/04/2024.
//

import Foundation

struct PDFUtils {
    
    static func getRowAdresse(_ coordonne : [String : Any]) -> [String] {
        PDFUtils.getTableauInfoAdresse(
            coordonne["rue"] as? String,
            (coordonne["code_postal"] as? Int32)?.description,
            coordonne["etage_appt"] as? String,
            coordonne["ville"] as? String
        )
    }
    
    static func getTableauInfoAdresse(_ rue : String?, _ codePostal: String?, _ etageAppt : String?, _ ville : String?) -> [String] {
        var tab : [String] = []
        if let rue = rue, !rue.isEmpty {
            tab.append(rue)
        }
        if let codepostal = codePostal, !codepostal.isEmpty {
            tab.append(codepostal)
        }
        if let etageAppt = etageAppt, !etageAppt.isEmpty {
            tab.append(etageAppt)
        }
        if let ville = ville, !ville.isEmpty {
            tab.append(ville)
        }
        
        return tab
    }
}
