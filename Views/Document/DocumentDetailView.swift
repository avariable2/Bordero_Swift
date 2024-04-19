//
//  FormDetailView.swift
//  Bordero
//
//  Created by Grande Variable on 13/04/2024.
//

import SwiftUI

struct DocumentDetailView: View, Saveable {
    @Environment(\.managedObjectContext) var moc
    @State private var selectedTab: Tab = .résumé
    
//    @State var viewModel : PDFViewModel
    
    @ObservedObject var document : Document
    
    init(viewModel: PDFViewModel?, document: Document?) {
        self.selectedTab = Tab.résumé
        if let doc = document {
            self.document = doc
        } else if let vm = viewModel {
            self.document = vm.getDocument()
        }
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
            
            ChoosenView(
                selectedElement: selectedTab,
                viewModel: $viewModel
            )
        }
        .navigationTitle("\(document.estFacture ? "Facture" : "Devis") # \(document.numeroDocument ?? "")")
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
    
    func save() {
        do {
            try moc.save()
            print("success")
        } catch _ {
            print("Error")
        }
    }
}

enum Tab : String, CaseIterable, Identifiable {
    case résumé, aperçu, historique
    
    var id: Self { self }
}

struct ChoosenView : View {
    var selectedElement : Tab
    @Binding var viewModel : PDFViewModel
    
    var body: some View {
        switch selectedElement {
        case .résumé:
            ResumeTabDetailViewPDF(documentData: viewModel.documentData)
        case .aperçu:
            PDFDisplayView(viewModel: viewModel, showToolbar: false)
        case .historique:
            HistoriqueTabDetailView(historique: viewModel.documentData.historique)
        }
    }
}

#Preview {
    NavigationStack {
        DocumentDetailView(viewModel: PDFViewModel(), document: nil)
    }
}

