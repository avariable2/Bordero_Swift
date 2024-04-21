//
//  FormDetailView.swift
//  Bordero
//
//  Created by Grande Variable on 13/04/2024.
//

import SwiftUI

struct DocumentDetailView: View {
    @Environment(\.managedObjectContext) var moc
    @State private var selectedTab: Tab = .résumé
    
//    @State var viewModel : PDFViewModel
    
    @ObservedObject var document : Document
    
//    init(viewModel : PDFViewModel) {
//        self.document = viewModel.getDocument(context: DataController.shared.container.viewContext)
//    }
    
    init(document : Document) {
        self.document = document
    }
    
    var body: some View {
        VStack {
            Picker("Afficher", selection: $selectedTab.animation()) {
                ForEach(Tab.allCases) { tab in
                    Text(tab.rawValue.capitalized).tag(tab.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.trailing, .leading])
            
//            ChoosenView(
//                selectedElement: selectedTab,
//                document: document
//            )
        }
        .navigationTitle("\(document.estDeTypeFacture ? "Facture" : "Devis") # \(document.numero)")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        
                    } label: {
                        Text("Modifier")
                    }
                    
                    Divider()
                    
                    Button {
                        
                    } label: {
                        Text("Dupliquer")
                    }
                    
                    Button {
                        
                    } label: {
                        Text("Exporter en PDF")
                    }
                
                    Divider()
                    
                    Button {
                        
                    } label: {
                        Text("Effacer")
                            .foregroundStyle(.red)
                    }
                    
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

//struct ChoosenView : View {
//    var selectedElement : Tab
//    var document : Document
//    
//    var body: some View {
//        switch selectedElement {
//        case .résumé:
//            ResumeTabDetailViewPDF(documentData: viewModel.documentData)
//        case .aperçu:
//            PDFDisplayView(viewModel: viewModel, showToolbar: false)
//        case .historique:
//            HistoriqueTabDetailView(historique: viewModel.documentData.historique)
//        }
//    }
//}

//#Preview {
//    NavigationStack {
//        DocumentDetailView(viewModel: PDFViewModel())
//    }
//}

