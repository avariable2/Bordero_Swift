//
//  SnapshotTypeActe.swift
//  Bordero
//
//  Created by Grande Variable on 19/04/2024.
//
//

import Foundation
import SwiftData


@Model public class SnapshotTypeActe {
    var date: Date?
    var id: UUID?
    var info_: String?
    var name_: String?
    var price_: Double? = 0
    var quantity: Double? = 0.0
    var remarque: String?
    var total_: Double? = 0
    var tva_: Double? = 0
    var uuidTypeActe: UUID?
    var version: Int32? = 0
    var estUnElementDe: Document?
    public init() {

    }
    
}
