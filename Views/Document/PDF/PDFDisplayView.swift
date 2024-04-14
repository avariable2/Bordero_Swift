//
//  DisplayPDFView.swift
//  Bordero
//
//  Created by Grande Variable on 25/03/2024.
//

import SwiftUI
import PDFKit


struct PDFDisplayView: View {
    @Environment(\.dismiss) var dismiss
    
    let viewModel : PDFViewModel
//    let showToolbar : Bool
    
//    init(viewModel: PDFViewModel, showToolbar : Bool = true) {
//        self.viewModel = viewModel
////        self.showToolbar = showToolbar
//    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if let url = viewModel.renderView() {
                    PDFKitView(url: url)
                } else {
                    VStack {
                        ProgressView()
                        Text("Génération du PDF en cours...")
                    }
                }
            }
            .navigationTitle("Aperçu")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Retour")
                    }
                }
            }
        }
    }
}
