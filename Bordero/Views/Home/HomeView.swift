//
//  HomeView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI
import CoreData
import ScrollableGradientBackground
import MijickGridView

struct ArticleData : Identifiable {
    let title : String
    let corps : String
    let image : String
    
    var id : UUID { UUID() }
}

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var context
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var gridViewConfig = GridView.Config()
    @State private var numberOfColumns = 1
    
    @FetchRequest(
        sortDescriptors: []
    ) var praticien: FetchedResults<Praticien>
    
    @State private var userHasSeenAllOnBoarding = false
    @State private var activeSheet: ActiveSheet?
    
    let articles : Array<ArticleData> = [
        ArticleData(
            title: "Les bonnes pratiques pour les factures de psychologie",
            corps: "Cette article couvre l'ensemble des bases et répond aux questions de l'importance des factures.",
            image: "ArticleImageFacture"
        ),
    ]
    
    var showNeediCloud : Bool
    
    var body: some View {
        HomeScrollableGradientBackgroundCustomView(
            contentTitle: {
                VStack {
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
                        .padding(.leading)
                        .contentMargins(.top, 0)
                    }
                }
            },
            heightPercentage: 0.35,
            maxHeight: 200,
            minHeight: 0,
            startColor: Color.green.opacity(0.85),
            endColor: colorScheme == .dark ? Color(uiColor: .systemBackground) : Color(uiColor: .secondarySystemBackground),
            navigationTitle: horizontalSizeClass == .compact ? "Résumé" : "",
            content: {
                
                SectionHomeComponentView(title: "Action rapide") {
                    BandeauCreateDocument()
                }
                
                SectionHomeComponentView(title: "Statistiques") {
                    ButtonShowStatistiquesPraticienView()
                }
                
                SectionHomeComponentView(title: "Articles") {
                    GridViewWrapper(articles: articles, config: $gridViewConfig, numberOfColumns: $numberOfColumns) { article in
                        ArticleComponentView(
                            titre: article.title,
                            sousTitre: article.corps,
                            image: article.image
                        )
                    }
                    .frame(height: calculateGridHeight(for: articles.count, columns: numberOfColumns))
                }
            }
            
        )
        .onAppear {
            if praticien.count == 0 {
                _ = Praticien(moc: context)
                DataController.saveContext()
            }
        }
        .sheet(item: $activeSheet) { type in
            switch(type) {
            case .parameters:
                ParametersView(activeSheet: $activeSheet, praticien: praticien.first)
            default:
                EmptyView()
            }
        }
    }
    
    private func calculateGridHeight(for itemsCount: Int, columns: Int, itemHeight: CGFloat = 380) -> CGFloat {
        let rows = (itemsCount + columns - 1) / columns // Calculate the number of rows needed
        return CGFloat(rows) * itemHeight // Calculate the total height
    }

    private func deleteAllEntities(named entityName: String) {
        #if DEBUG
        // Créer un fetch request pour l'entité cible
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        
        // Créer une requête de suppression par lot
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        // Obtenir le contexte de vue de votre conteneur persistant
        let context = DataController.shared.container.viewContext
        
        do {
            // Exécuter la requête de suppression par lot
            try context.execute(deleteRequest)
            print("Toutes les occurrences de \(entityName) ont été supprimées.")
        } catch {
            print("Erreur lors de la suppression des occurrences de \(entityName): \(error)")
        }
        #endif
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
        
        BandeauiCloud(showNeediCloud: showNeediCloud)
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
                .frame(maxHeight: 120)
            
            VStack(alignment: .leading) {
                if !name.isEmpty {
                    Text(name)
                        .font(.title)
                        .fontWeight(.bold)
                }
                
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
                
                if showNeediCloud == false {
                    Text("Synchronisé")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fontWeight(.medium)
                }
            }
            .padding([.leading, .trailing])
            
            Spacer()
            
            BandeauiCloud(showNeediCloud: showNeediCloud)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct BandeauiCloud : View {
    var showNeediCloud : Bool
    
    var body: some View {
        if showNeediCloud {
            GroupBox {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Données Bordero non synchronisées")
                        .bold()
                    
                    Text("Vos données et vos documents ne sont pas synchronisés. En tant que praticien, il est important d'avoir un point de sauvegarde de vos données.")
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
}

#Preview {
    HomeView(showNeediCloud: true)
}

