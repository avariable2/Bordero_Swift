//
//  HomeView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI
import ScrollableGradientBackground

struct HomeView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme
    @FetchRequest(sortDescriptors: []) var praticien: FetchedResults<Praticien>
    
    @State private var userHasSeenAllOnBoarding = false
    @State private var activeSheet: ActiveSheet?
    
    var showNeediCloud : Bool

    var body: some View {
        HomeScrollableGradientBackgroundCustomView(
            heightPercentage: 0.35,
            maxHeight: 200,
            minHeight: 0,
            startColor: Color.green.opacity(0.85),
            endColor: colorScheme == .dark ? Color(uiColor: .systemBackground) : Color(uiColor: .secondarySystemBackground),
            navigationTitle: horizontalSizeClass == .compact ? "Résumé" : "",
            content: {
                if horizontalSizeClass == .compact {
                    TitleSectionCompact(
                        activeSheet: $activeSheet,
                        profilPictureData: praticien.first?.profilPicture,
                        showNeediCloud: showNeediCloud
                    )
                } else {
                    TitleSectionIpad(
                        activeSheet: $activeSheet,
                        name: praticien.first?.firstname ?? "",
                        profilPictureData: praticien.first?.profilPicture,
                        showNeediCloud: showNeediCloud
                    )
                    .contentMargins(.top, 0)
//                    .border(Color.black)
                }
                
                SectionHomeComponentView(title: "Action rapide") {
                    BandeauCreateDocument()
                }
                
                SectionHomeComponentView(title: "Statistiques") {
                    StatistiquePaticientView()
                }
                
                SectionHomeComponentView(title: "Articles") {
                    Grid() {
                        GridRow {
                            ArticleComponentView(
                                titre: "Les bonnes pratiques pour les factures de psychologie",
                                sousTitre: "Cette article couvre l'ensemble des bases et répond aux question de l'importance des factures.",
                                image: "ArticleImageFacture"
                            )
                            
                        }
                    }
                    
                }
            }
        )
        .sheet(item: $activeSheet) { type in
            switch(type) {
            case .parameters:
                ParametersView(activeSheet: $activeSheet, praticien: praticien.first)
            default:
                EmptyView()
            }
        }
    }
}

private struct TitleSectionCompact : View {
    @Binding var activeSheet: ActiveSheet?
    var profilPictureData : Data?
    var showNeediCloud : Bool
    
    var body: some View {
        HStack {
            Text("Résumé")
                .bold()

            Spacer()

            ProfilButton(activeSheet: $activeSheet, userImage: profilPictureData)
                .frame(height: 40)
        }
        .font(.largeTitle)
        
        if showNeediCloud {
            GroupBox {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Données Bordero non synchronisées")
                        .bold()
                    
                    Text("Vos données et vos documents ne sont pas synchronisées. En tant que praticien, il est important d'avoir un point de sauvegarde de vos données.")
                        .foregroundStyle(.secondary)
                    
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Ouvrir Réglages")
                    }
                }
            } label: {
                Text("état de la sauvegarde".uppercased())
                    .bold()
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .groupBoxStyle(GroupBoxStyleRememberiCloud())
            .padding(.bottom)
        }
    }
}

private struct TitleSectionIpad : View {
    @Binding var activeSheet: ActiveSheet?
    var name : String
    var profilPictureData : Data?
    var showNeediCloud : Bool
    
    var body: some View {
        HStack {
            ProfilImageView(imageData: profilPictureData)
                .font(.system(size: 70))
                .shadow(radius: 5)
                .frame(maxHeight: 150)
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Button {
                    activeSheet = .parameters
                } label: {
                    HStack {
                        Text("Profil")
                            .font(.headline)
                        
                        Image(systemName: "chevron.right")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.secondary)
                }
                .tint(.primary)
                
                Text("Synchronisation")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fontWeight(.medium)
            }
            .padding([.leading, .trailing])
            
            Spacer()
            
            if showNeediCloud {
                GroupBox {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Données Bordero non synchronisées")
                            .bold()
                        
                        Text("Vos données et vos documents ne sont pas synchronisées. En tant que praticien, il est important d'avoir un point de sauvegarde de vos données.")
                            .foregroundStyle(.secondary)
                        
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString),
                               UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Text("Ouvrir Réglages")
                        }
                    }
                } label: {
                    Text("état de la sauvegarde".uppercased())
                        .bold()
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: 500)
                .groupBoxStyle(GroupBoxStyleRememberiCloud())
            }
        }
        .padding(.bottom)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HomeView(showNeediCloud: true)
}

