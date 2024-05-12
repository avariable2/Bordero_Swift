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
    let showToolbar : Bool
    
    @State var fileUrl : URL? = nil
    
    init(viewModel: PDFViewModel, showToolbar : Bool = true) {
        self.viewModel = viewModel
        self.showToolbar = showToolbar
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if let url = fileUrl {
                    PDFKitView(url: url)
                } else {
                    VStack {
                        ProgressView()
                        Text("Génération du PDF en cours...")
                    }
                }
            }
            .onAppear {
                if viewModel.pdfModel.urlFilePreview == nil {
                    fileUrl = viewModel.renderView()
                    viewModel.pdfModel.urlFilePreview = fileUrl
                } else {
                    fileUrl = viewModel.renderView(viewModel.pdfModel.urlFilePreview)
                }
            }
            .navigationTitle("Aperçu")
            .toolbar {
                if showToolbar {
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
}
