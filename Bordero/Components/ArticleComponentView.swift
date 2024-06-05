//
//  ArticleComponentView.swift
//  Bordero
//
//  Created by Grande Variable on 24/02/2024.
//

import SwiftUI

struct ArticleComponentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var afficherContenu = false
    
    var titre : String
    var sousTitre : String
    var image : String
    
    var body: some View {
        Button {
            afficherContenu = true
        } label: {
            VStack(alignment: .leading) {
                Image(image)
                    .resizable()
                    .frame(height: 200)
                    .scaledToFit()
                    .clipShape(.rect(topLeadingRadius: 10, topTrailingRadius: 10))
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(titre)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(sousTitre)
                        .font(.headline)
                        .fontWeight(.regular)
                }
                .frame(minHeight: 140, alignment: .top)
                .foregroundColor(.primary)
                .padding([.leading, .trailing, .bottom])
                
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor)
            )
        }
        .sheet(isPresented: $afficherContenu) {
            NavigationStack {
                Article1(image: image)
                    .navigationTitle("Article utile sur la facturation")
                    .navigationBarTitleDisplayMode(.inline)
            }
            
        }
    }
    
    var backgroundColor : Color {
        if colorScheme == .dark {
            Color(UIColor.systemGray6)
        } else {
            .white
        }
    }
}

private struct Article1 : View {
    @Environment(\.dismiss) var dismiss
    
    var image : String
    
    var body: some View {
        ScrollView {
            Image(image)
                .resizable()
                .frame(height: 360)
                .scaledToFit()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Les bonnes pratiques pour les factures de psychologie")
                    .font(.largeTitle)
                    .bold()
                Text("La facturation en psychologie est essentielle pour assurer une gestion efficace du cabinet, maintenir des relations de confiance avec les patients et respecter les obligations légales.")
                Text("Voici six bonnes pratiques à adopter pour une facturation transparente et professionnelle, illustrant l’impact des logiciels de facturation sur la gestion administrative.")
                
                Text("1. Établir des Tarifs Clairs et Transparents")
                    .font(.title3)
                    .bold()
                Text("Dès le premier contact, il est crucial d’informer les patients des tarifs des consultations. Les tarifs doivent être affichés de manière claire, que ce soit sur le site internet du cabinet ou par le biais de brochures disponibles lors des premières consultations.")
                Text("Cette transparence permet d’éviter toute confusion et de garantir que les patients sont pleinement informés des coûts associés aux services.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                // Mark: - Nouvelle section
                Text("2. Utiliser des Logiciels de Facturation Adaptés")
                    .font(.title3)
                    .bold()
                Text("L’utilisation de logiciels de facturation permet de créer des factures professionnelles, de suivre les paiements et de générer des rapports financiers détaillés. Ces outils intégrés automatisent la saisie des données, réduisent les erreurs et accélèrent le processus de facturation, permettant ainsi aux professionnels de se concentrer davantage sur leurs patients.")
                Text("Selon une étude, l’adoption de ces logiciels réduit le temps consacré aux tâches administratives de 30% en moyenne et augmente l’efficacité de la facturation de 20%")
                
                Text("3. Assurer la Confidentialité des Informations")
                    .font(.title3)
                    .bold()
                Text("La confidentialité est une priorité en psychologie. Les factures doivent être rédigées de manière à protéger les informations sensibles des patients.")
                Text("Il est recommandé d’utiliser des descriptions génériques pour les services rendus afin de ne pas compromettre la confidentialité des patients.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("4. Respecter les Obligations Légales et Fiscales")
                    .font(.title3)
                    .bold()
                Text("Les psychologues doivent se conformer aux réglementations fiscales en vigueur, incluant la délivrance de factures conformes aux normes légales, la déclaration des revenus et le paiement des impôts correspondants. Il est conseillé de consulter un comptable pour s’assurer que toutes les obligations légales et fiscales sont respectées.")
                
                Text("5. Offrir des Modalités de Paiement Flexibles")
                    .font(.title3)
                    .bold()
                Text("Pour faciliter les paiements, proposez diverses options comme les chèques, les virements bancaires, et les paiements par carte de crédit. Offrir des modalités de paiement flexibles peut réduire les retards de paiement et améliorer la satisfaction des patients. Les cabinets utilisant ces solutions voient souvent une amélioration de la collecte des paiements et une réduction des impayés de 15 à 25%.")
                
                Text("6. Gérer les Impayés de Manière Professionnelle")
                    .font(.title3)
                    .bold()
                Text("Les impayés peuvent survenir malgré toutes les précautions. Environ 30% des psychologues ont signalé des difficultés avec des paiements en retard ou non effectués.")
                Text("Pour gérer ces situations, envoyez des rappels polis et, si nécessaire, proposez des plans de paiement. En dernier recours, envisagez de faire appel à un service de recouvrement, en veillant à ce que cela soit fait de manière éthique.")
            }
            .trackEventOnAppear(event: .articleRead, category: .userEngagement, parameters: [
                "article_id": 1,
                "article_title": "Les bonnes pratiques pour les factures de psychologie"
            ])
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("OK", role: .destructive) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray
        
        HStack(spacing: 30) {
            ArticleComponentView(titre: "Suivi de vos traitements", sousTitre: "Découvrez en quoi il est important de suivre les traitements que vous prenez.", image: "ArticleImageFacture")
            
            ArticleComponentView(titre: "Pourquoi la santé\nauditive est-elle importante?", sousTitre: "Obtenez des statistiques sur votre audition et découvrez comment la préserver.", image: "ArticleImageFacture")
            
            ArticleComponentView(titre: "Ce que signifie un niveau de santé cardoiovasculaire faible", sousTitre: "Et ce que vous pouvez faire pour l'améliorer.", image: "ArticleImageFacture")
        }
        
    }
}
