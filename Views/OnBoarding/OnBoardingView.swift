//
//  OnBoardingView.swift
//  Bordero
//
//  Created by Grande Variable on 25/02/2024.
//

import SwiftUI

struct OnBoardingView : View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                
                
                Text("Bienvenue dans Bordero")
                    .font(.largeTitle)
                    .padding()
                
                Text("👋")
                    .font(.system(size: 60))
            }
            
            RowOnBoarding(
                titre: "Créer facilement vos documents administratifs",
                sousTitre: "Tous est mis en place pour accélérer l'édition de vos documents et d'etre le plus pratique possible pour vous et vos clients.") {
                Image(systemName: "doc.text.below.ecg.fill")
                    .foregroundStyle(.purple, .primary)
            }
            
            RowOnBoarding(
                titre: "Tous vos données synchronisé sur tous vos appareils",
                sousTitre: "Pas besoin de vous inscrire ou de vous connecter. Récupérer tous vos fichiers à travers vos différents appareils") {
                Image(systemName: "icloud.circle.fill")
                    .foregroundStyle(.white, .blue)
            }
            
            RowOnBoarding(
                titre: "Analyse et suivi de vos payements",
                sousTitre: "Permet un suivis de vos documents et d'analyser les tendances de votre activités") {
                Image(systemName: "chart.bar.xaxis.ascending")
                    .foregroundStyle(.red, .primary)
            }

            Button {
                
            } label: {
                Text("Continuer")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
    }
}

struct RowOnBoarding<Content : View> : View {
    var titre : String
    var sousTitre : String
    @ViewBuilder var image : Content
    
    var body: some View {
        HStack(spacing: 20) {
            image
                .imageScale(.large)
            
            VStack(alignment: .leading) {
                Text(titre)
                    .font(.headline)
                    .bold()
                
                Text(sousTitre)
                    .font(.footnote)
            }
        }
        
        .padding()
    }
}

#Preview {
    OnBoardingView()
}
