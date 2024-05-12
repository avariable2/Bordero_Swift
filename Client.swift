//
//  Client.swift
//  Bordero
//
//  Created by Grande Variable on 19/04/2024.
//
//

import Foundation
import SwiftData


@Model public class Client {
    var adresse1: Adresse?
    var adresse2: Adresse?
    var adresse3: Adresse?
    var code_entreprise: String?
    var email_: String?
    var firstname_: String?
    var id: UUID?
    var name_: String?
    var phone_: String?
    var version: Int32? = 0
    public init() {

    }
    
}
