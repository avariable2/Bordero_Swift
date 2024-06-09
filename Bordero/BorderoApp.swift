//
//  BorderoApp.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI
import CoreData
import FirebaseCore
import MijickPopupView

@main
struct BorderoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    private var dataController = DataController.shared
    private var userController = UseriCloudController()
    
    init() {
        // Définir le délégué
        UNUserNotificationCenter.current().delegate = appDelegate
    }
    
    
    var body: some Scene {
        WindowGroup {
            switch userController.accountAvailable {
            case .isLoading:
                HomeView(showNeediCloud: true)
                    .redacted(reason: .placeholder)
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .implementPopupView()
            case .connected, .notConnected:
                ContentView(userNeediCloud: userController.accountAvailable)
                    .onAppear(perform: checkAndCreatePraticien) // Instanciate in firts launch an praticien for use the app everywhere
                    .onChange(of: userController.accountAvailable) { oldValue, newValue in
                        DataController.shared.updateICloudSettings()
                    }
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .implementPopupView()
            }
                
        }
    }
    
    func checkAndCreatePraticien() {
        let context = dataController.container.viewContext
        let fetchRequest : NSFetchRequest<Praticien> = Praticien.fetchRequest()
        
        do {
            let praticien = try context.fetch(fetchRequest)
            if praticien.isEmpty {
                let praticien = Praticien(context: context)
                praticien.id = FormPraticienView.uuidPraticien
                praticien.defaultRangeDateEcheance_ = Int16(DateEcheanceParams.trente.value)
                try context.save()
            }
        } catch {
            print("Erreur lors de la vérification de l'entité Praticien : \(error)")
        }
    }
}

class AppDelegate : NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
