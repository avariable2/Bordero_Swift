//
//  FormDetailView.swift
//  Bordero
//
//  Created by Grande Variable on 13/04/2024.
//

import SwiftUI

struct DocumentDetailView: View {
    @State private var selectedTab: Tab = .résumé
    
    let documentData : PDFModel
    
    var body: some View {
        VStack {
            Picker("Afficher", selection: $selectedTab.animation()) {
                ForEach(Tab.allCases) { tab in
                    Text(tab.rawValue.capitalized).tag(tab.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.trailing, .leading])
            
            ChoosenView(
                selectedElement: selectedTab,
                documentData: documentData
            )
        }
        .navigationTitle("\(documentData.optionsDocument.typeDocument.rawValue.capitalized) # \(documentData.optionsDocument.numeroDocument)")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                }

            }
        }
    }
}

enum Tab : String, CaseIterable, Identifiable {
    case résumé, aperçu, historique
    
    var id: Self { self }
}

struct ChoosenView : View {
    var selectedElement : Tab
    let documentData : PDFModel
    let viewModel : PDFViewModel
    
    init(selectedElement: Tab, documentData: PDFModel) {
        self.selectedElement = selectedElement
        self.documentData = documentData
        self.viewModel = PDFViewModel(documentData: documentData)
    }
    
    var body: some View {
        switch selectedElement {
        case .résumé:
            ResumeTabDetailViewPDF(documentData: documentData)
        case .aperçu:
            PDFDisplayView(viewModel: viewModel, showToolbar: false)
        case .historique:
            HistoriqueTabDetailView(historique: documentData.historique)
        }
    }
}

#Preview {
    NavigationStack {
        DocumentDetailView(documentData: PDFModel())
    }
}

