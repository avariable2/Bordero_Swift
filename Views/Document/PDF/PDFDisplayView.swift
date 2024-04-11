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
    @ObservedObject var viewModel : PDFViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                if let url = viewModel.generatedPDFURL {
                    PDFKitView(url: url)
                } else {
                    VStack {
                        ProgressView()
                        Text("Génération du PDF en cours...")
                    }
                }
            }
            .onAppear {
                viewModel.renderView()
            }
            .navigationTitle("Aperçus")
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
