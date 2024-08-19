//
//  IconStatusDocument.swift
//  Bordero
//
//  Created by Grande Variable on 24/07/2024.
//

import SwiftUI

struct IconStatusDocument: View {
    var status : Document.Status
    
    var body: some View {
        switch status {
        case Document.Status.created:
            Image(systemName: "doc.badge.clock.fill")
                .foregroundStyle(.orange)
        case Document.Status.payed:
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(.green)
        case Document.Status.send:
            Image(systemName: "checkmark.bubble.fill")
                .foregroundStyle(.blue)
        case Document.Status.retard :
            Image(systemName: "hourglass.tophalf.filled")
                .foregroundStyle(.pink)
        default:
            Image(systemName: "questionmark.circle.fill")
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    IconStatusDocument(status: Document.example.determineStatut())
}
