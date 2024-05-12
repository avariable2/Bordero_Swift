//
//  Praticien+helper.swift
//  Bordero
//
//  Created by Grande Variable on 27/02/2024.
//

import Foundation
import CoreData

extension Praticien {
    
    var firstname : String {
        get { firstname_ ?? "" }
        set { firstname_ = newValue }
    }
    
    var lastname : String {
        get { lastname_ ?? "" }
        set { lastname_ = newValue }
    }
    
    var phone : String {
        get { phone_ ?? "" }
        set { phone_ = newValue }
    }
    
    var email : String {
        get { email_ ?? "" }
        set { email_ = newValue }
    }
    
    var website : String {
        get { website_ ?? "" }
        set { website_ = newValue }
    }
    
    var siret : String {
        get { siret_ ?? "" }
        set { siret_ = newValue }
    }
    
    var adeli : String {
        get { adeli_ ?? "" }
        set { adeli_ = newValue }
    }
    
    func getAdresseSurUneLigne() -> String {
        if let coordonne = self.adresse1 {
            return PDFUtils.getTableauInfoAdresse(
                coordonne["etage_appt"] as? String,
                coordonne["rue"] as? String,
                (coordonne["code_postal"] as? Int32)?.description,
                coordonne["ville"] as? String
            ).formatted(.list(type: .and, width: .narrow))
        }
        return ""
    }
    
    convenience init(
        firstname : String,
        lastname : String,
        phone : String,
        email : String,
        website : String,
        siret : String,
        adeli : String,
        context : NSManagedObjectContext) {
            self.init(context: context)
            self.firstname = firstname
            self.lastname = lastname
            self.phone  = phone
            self.email = email
            self.website = website
            self.siret = siret
            self.adeli = adeli
    }
}
