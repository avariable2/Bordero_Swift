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
            ContentView(userNeediCloud: userController.accountAvailable)
                .redacted(reason: userController.accountAvailable == .isLoading ? .placeholder : [])
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .implementPopupView()
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
