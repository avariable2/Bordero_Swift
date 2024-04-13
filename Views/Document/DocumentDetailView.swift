//
//  FormDetailView.swift
//  Bordero
//
//  Created by Grande Variable on 13/04/2024.
//

import SwiftUI

struct DocumentDetailView: View {
    @State private var selectedTab: Tab = .résumé
    
    var body: some View {
        VStack {
            Picker("Flavor", selection: $selectedTab.animation()) {
                ForEach(Tab.allCases) { tab in
                    Text(tab.rawValue.capitalized).tag(tab.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.trailing, .leading])
            
            ChoosenView(selectedElement: selectedTab)
        }
        .navigationTitle("Facture # 001")
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
    
    var body: some View {
        switch selectedElement {
        case .résumé:
            ResumeTabDetailViewPDF(client: Client(firstname: "Adriennne", lastname: "VARY", phone: "0102030405", email: "exemple.vi@gmail.com", context: DataController.shared.container.viewContext))
        case .aperçu:
            EmptyView()
        case .historique:
            EmptyView()
        }
    }
}

#Preview {
    NavigationStack {
        DocumentDetailView()
    }
    
}

struct GroupBoxBorderoStyle<V: View>: GroupBoxStyle {
    var color: Color
    var destination : V
    var date: Date?
    
    @ScaledMetric var size : CGFloat = 1
    
    func makeBody(configuration: Configuration) -> some View {
        NavigationLink(destination: destination) {
            GroupBox(label: HStack {
                configuration.label.foregroundColor(color)
                Spacer()
                if date != nil {
                    Text("\(date!)").font(.footnote).foregroundColor(.secondary).padding(.trailing, 4)
                }
                Image(systemName: "chevron.right").foregroundColor(Color(.systemGray4)).imageScale(.small)
            }) {
                configuration.content.padding(.top)
            }
        }.buttonStyle(PlainButtonStyle())
    }
}

struct HealthValueView: View {
    var value: String
    var unit: String
    
    @ScaledMetric var size: CGFloat = 1
    
    @ViewBuilder var body: some View {
        HStack {
            Text(value).font(.system(size: 24 * size, weight: .bold, design: .rounded)) + Text(" \(unit)").font(.system(size: 14 * size, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
            Spacer()
        }
    }
}

