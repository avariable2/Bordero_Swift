//
//  TypeActe.swift
//  Bordero
//
//  Created by Grande Variable on 19/04/2024.
//
//

import Foundation
import SwiftData


@Model public class TypeActe {
    var id: UUID?
    var info_: String?
    var name_: String?
    var price_: Double? = 0
    var total_: Double? = 0
    var tva_: Double? = 0
    var version: Int32? = 0
    public init() {

    }
    
}
