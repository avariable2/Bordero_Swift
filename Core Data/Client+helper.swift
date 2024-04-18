//
//  Client+helper.swift
//  Bordero
//
//  Created by Grande Variable on 10/04/2024.
//

import Foundation
import CoreData

extension Client {
    
    var firstname : String {
        get { firstname_ ?? "" }
        set { firstname_ = newValue }
    }
    
    var lastname : String {
        get { name_ ?? "" }
        set { name_ = newValue }
    }
    
    var email : String {
        get { email_ ?? "" }
        set { email_ = newValue }
    }
    
    var phone : String {
        get { phone_ ?? "" }
        set { phone_ = newValue }
    }
    
    func getAdresseSurUneLigne() -> String {
        if let tabAddr = self.adresses as? Set<Adresse>, let coordonne = tabAddr.first {
            
            return PDFUtils.getTableauInfoAdresse(coordonne).formatted(.list(type: .and, width: .narrow))
        }
        return ""
    }
    
    convenience init(
        firstname : String,
        lastname : String,
        phone : String,
        email : String,
        context : NSManagedObjectContext) {
            self.init(context: context)
            self.firstname = firstname
            self.lastname = lastname
            self.phone  = phone
            self.email = email
    }
}
