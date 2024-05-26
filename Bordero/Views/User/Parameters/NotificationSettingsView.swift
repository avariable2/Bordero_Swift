//
//  NotificationSettingsView.swift
//  Bordero
//
//  Created by Grande Variable on 25/05/2024.
//

import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @State var praticien : Praticien
    @State var activeNotifications = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Activer les notifications", isOn: $activeNotifications)
                    .onChange(of: activeNotifications) { oldValue, newValue in
                        if newValue == true {
                            requestAuthorizationNotification()
                        }
                    }
            } header: {
                
            } footer: {
                Text("Ces notifications serviront uniquement à vous alerter en cas de date d'échéance dépassé sur un document.")
            }
            
        }
        .navigationTitle("Notifications")
        .onAppear(perform: checkNotificationPermission)
    }
    
    func requestAuthorizationNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                praticien.hasAcceptNotification = true
                DataController.saveContext()
            } else if let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func checkNotificationPermission() {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    switch settings.authorizationStatus {
                    case .authorized, .provisional, .ephemeral:
                        activeNotifications = true
                    case .denied, .notDetermined:
                        activeNotifications = false
                    @unknown default:
                        activeNotifications = false
                    }
                }
            }
        }
}

#Preview {
    NotificationSettingsView(praticien: Praticien.example)
}
