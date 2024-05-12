//
//  Praticien.swift
//  Bordero
//
//  Created by Grande Variable on 19/04/2024.
//
//

import Foundation
import SwiftData


@Model public class Praticien {
    var adeli_: String?
    var adresse1: Adresse?
    var applyTVA: Bool?
    var carte: Bool?
    var cheque: Bool?
    var email_: String?
    var espece: Bool?
    var firstname_: String?
    var id: UUID?
    var lastname_: String?
    var logoSociete: Data?
    var nom_proffession: String?
    var phone_: String?
    var profilPicture: Data?
    var signature: Data?
    var siret_: String?
    var version: Int32? = 0
    var virement_bancaire: Bool?
    var website_: String?
    public init() {

    }
    
}
