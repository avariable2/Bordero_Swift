//
//  OnBoardingView.swift
//  Bordero
//
//  Created by Grande Variable on 25/02/2024.
//

import SwiftUI

struct OnBoardingView : View {
    @Environment(\.dismiss) var dismiss
    @State private var userHasSeenAllOnBoarding = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                
                Spacer()
                
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

                Spacer()
                
            }
            .padding()
            .interactiveDismissDisabled(!userHasSeenAllOnBoarding)
            .safeAreaInset(edge: .bottom) {
                NavigationLink {
                    ConfidentialiteOnBoardingView(userHasSeenAllOnBoarding: $userHasSeenAllOnBoarding)
                } label: {
                    Text("Continuer")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
            }
        }
        
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
                .frame(height: 50)
            
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

struct ConfidentialiteOnBoardingView : View {
    @Binding var userHasSeenAllOnBoarding : Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(alignment: .center) {
                        Image(systemName: "lock.rectangle.stack.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 140)
                            .foregroundStyle(.white, .green)
                            .padding()
                        
                        Text("Sécurité de vos données")
                            .font(.largeTitle)
                            .bold()
                            
                    }
                    
                    Text("Vos données Bordero sont stockées sur iCloud et ne peuvent être lues par personne sans votre permission, pas même Bordero, et ne seront jamais revendues à une tierce partie.")
                    
                    Text("Vos données renseignées sont uniquement utilisés pour l'usage de cette application et ne sorte pas de celle ci. Vous pouvez les modifier à tous moment.")
                }
                .padding()
                .multilineTextAlignment(.center)
            }
            .interactiveDismissDisabled(!userHasSeenAllOnBoarding)
            .safeAreaInset(edge: .bottom) {
                NavigationLink {
                    CoordooneesPraticienView(userHasSeenAllOnBoarding: $userHasSeenAllOnBoarding)
                } label: {
                    Text("Continuer")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
            }
        }
    }
}

struct CoordooneesPraticienView : View {
    @Binding var userHasSeenAllOnBoarding : Bool
    
    var body: some View {
        NavigationStack {
            FormPraticienView()
                .interactiveDismissDisabled(!userHasSeenAllOnBoarding)
        }
        .navigationTitle("Vos coordonnées")
    }
}

#Preview {
//    OnBoardingView()
    ConfidentialiteOnBoardingView(userHasSeenAllOnBoarding: .constant(false))
}
