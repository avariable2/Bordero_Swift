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
            case .notConnected:
                ErrorDisplayWithiCloudView()
            case .connected:
                ContentView()
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
            Text("Vous n'êtes pas connecté à iCloud")
            
            VStack(spacing: 30) {
                Text("L'application en à besoin pour fonctionner et synchroniser vos données sur vos différents appareils.")
                Text("Redémarré l'application une fois connecté.")
            }
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .font(.largeTitle)
        .multilineTextAlignment(.center)
    }
}

#Preview {
    OnBoardingView(userHasSeenAllOnBoarding: .constant(true))
}
