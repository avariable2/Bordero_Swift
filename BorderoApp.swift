//
//  BorderoApp.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI

@main
struct BorderoApp: App {
    
    private var dataController = DataController.shared
    private var userController = UseriCloudController()
    
    var body: some Scene {
        WindowGroup {
            switch userController.accountAvailable {
            case .isLoading:
                ProgressView()
//            case .notConnected:
//                ErrorDisplayWithiCloudView()
            case .connected, .notConnected:
                ContentView(userNeediCloud: userController.accountAvailable)
                    .onChange(of: userController.accountAvailable) { oldValue, newValue in
                        DataController.shared.updateICloudSettings()
                    }
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    
            }
        }
    }
}

struct ErrorDisplayWithiCloudView :View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "cloud.fill")
                .foregroundColor(.accentColor)
                .font(.largeTitle)
            
            Text("Vous n'êtes pas connecté à iCloud")
                .font(.largeTitle)
            
            VStack(spacing: 30) {
                Text("L'application en à besoin pour fonctionner et synchroniser vos données sur vos différents appareils.")
                Text("Un redémarrage de l'application une fois connecté peut etre nécessaire.")
            }
                .font(.body)
                .foregroundColor(.secondary)
            
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Activer dans les paramètres")
                    .font(.title3)
            }
            
            Spacer()
        }
        .padding()
        
        .multilineTextAlignment(.center)
    }
}

#Preview {
//    OnBoardingView(userHasSeenAllOnBoarding: .constant(true))
    ErrorDisplayWithiCloudView()
}
