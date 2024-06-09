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
                    .onChange(of: userController.accountAvailable) { oldValue, newValue in
                        DataController.shared.updateICloudSettings()
                    }
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .implementPopupView()
            }
                
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
