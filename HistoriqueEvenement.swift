//
//  HistoriqueEvenement.swift
//  Bordero
//
//  Created by Grande Variable on 19/04/2024.
//
//

import Foundation
import SwiftData


@Model public class HistoriqueEvenement {
    var date: Date?
    var id: UUID?
    var nom: String?
    var version: Int32? = 0
    var correspond: Document?
    public init() {

    }
    
}
