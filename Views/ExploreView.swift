//
//  NavigationView.swift
//  Bordero
//
//  Created by Grande Variable on 23/02/2024.
//

import SwiftUI

struct ExploreView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [], predicate: PraticienUtils.predicate) var praticien : FetchedResults<Praticien>
    
    @State private var activeSheet: ActiveSheet?
    
    var body: some View {
        List {
            Section("Action rapides") {
                Button {
                    activeSheet = .createTypeActe
                } label: {
                    RowExploreView(
                        text: "Ajouter un acte",
                        systemName: "cross.vial",
                        primaryColor: .mint,
                        secondaryColor : .mint,
                        needToShowArrow : true
                    )
                }
                
                NavigationLink {
                    ListTypeActe(applyTvaOnTypeActe: praticien.first?.applyTVA ?? false)
                } label: {
                    RowExploreView(
                        text: "Liste des actes",
                        systemName: "cross.case.fill",
                        primaryColor: .purple,
                        secondaryColor: .purple
                    )
                }
                
                NavigationLink {
                    DocumentFormView()
                } label: {
                    RowExploreView(
                        text: "Créer document",
                        systemName: "doc.badge.plus",
                        primaryColor: .blue,
                        secondaryColor : .blue
                    )
                }
                
                NavigationLink {
                    ListDocument()
                } label: {
                    RowExploreView(
                        text: "Liste des docs",
                        systemName: "doc.text.magnifyingglass",
                        primaryColor: .gray,
                        secondaryColor: .blue
                    )
                }
            }
            
            Section {
                Button {
                    activeSheet = .parameters
                } label: {
                    RowExploreProfilView(praticien: praticien.first)
                }
                
            }
        }
        .navigationTitle("Parcourir")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
            }
        }
        .headerProminence(.increased)
        .sheet(item: $activeSheet) { item in
            
            switch item {
            case .createTypeActe:
                FormTypeActeSheet(applyTVA: praticien.first?.applyTVA ?? false, onCancel: {
                    activeSheet = nil
                })
                .presentationDetents([.large])
            case .createClient:
                FormClientSheet(onCancel: {
                    activeSheet = nil
                }, onSave: {
                    activeSheet = nil
                })
                .presentationDetents([.large])
                
            case .parameters:
                ParametersView(activeSheet: $activeSheet, praticien: praticien.first)
            default:
                EmptyView() // IMPOSSIBLE
            }
        }
    }
}

struct RowExploreView : View {
    let text : String
    let systemName : String
    let primaryColor : Color
    var secondaryColor : Color = .primary
    
    var needToShowArrow : Bool = false
    
    var body: some View {
        Label {
            if needToShowArrow {
                HStack {
                    Text(text)
                        .padding([.top, .bottom], 8)
                        .tint(.primary)
                        .font(.headline)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.tertiary)
                        .tint(.primary)
                }
            } else {
                Text(text)
                    .padding([.top, .bottom], 8)
                    .tint(.primary)
                    .font(.headline)
            }
            
        } icon: {
            Image(systemName: systemName)
                .foregroundStyle(primaryColor, secondaryColor)
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .fontWeight(.semibold)
        }
        .fontWeight(.medium)
    }
}

struct RowExploreProfilView : View {
    @State var praticien : Praticien?
    
    var body: some View {
        Label {
            HStack {
                Text("Paramètres")
                    .padding([.top, .bottom], 8)
                    
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.tertiary)
            }
            .tint(.primary)
        } icon: {
            ProfilImageView(imageData: praticien?.profilPicture)
                .font(.title3)
        }
        .fontWeight(.medium)
    }
}

#Preview {
    NavigationStack {
        ExploreView()
    }
}
