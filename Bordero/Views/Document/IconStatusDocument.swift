//
//  IconStatusDocument.swift
//  Bordero
//
//  Created by Grande Variable on 24/07/2024.
//

import SwiftUI

struct IconStatusDocument: View {
    @ObservedObject var document : Document
    
    var body: some View {
        switch document.determineStatut() {
        case Document.Status.created.rawValue:
            Image(systemName: "doc.badge.clock.fill")
                .foregroundStyle(.orange)
        case Document.Status.payed.rawValue:
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(.green)
        case Document.Status.send.rawValue:
            Image(systemName: "checkmark.bubble.fill")
                .foregroundStyle(.blue)
        default:
            Image(systemName: "questionmark.circle.fill")
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    IconStatusDocument(document: Document.example)
}
