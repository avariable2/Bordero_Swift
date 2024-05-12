//
//  Document.swift
//  Bordero
//
//  Created by Grande Variable on 19/04/2024.
//
//

import Foundation
import SwiftData


@Model public class Document {
    var dateEcheance: Date?
    var dateEmission: Date?
    var estFacture: Bool?
    var id: UUID?
    var note: String?
    var numeroDocument: String?
    var payementAllow: DocumentPayementAllow?
    var payementFinish: Bool?
    var payementUse: String?
    var remise: Remise?
    var snapshotClient: SnapshotClient?
    var snapshotPraticien: SnapshotPraticien?
    var totalHT: Double? = 0.0
    var totalTTC: Double? = 0.0
    var totalTVA: Double? = 0.0
    var version: Int32? = 0
    var elements: [SnapshotTypeActe]?
    @Relationship(inverse: \HistoriqueEvenement.correspond) var historique: [HistoriqueEvenement]?
    public init() {

    }
    
}
