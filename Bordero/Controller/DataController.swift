//
//  DataController.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import CoreData
import Foundation
import CloudKit
import Observation

@Observable class DataController {
    static let shared = DataController()
    
    var container: NSPersistentCloudKitContainer
    
    static var sharedStoreURL: URL {
        let id = "group.com.bigVariable.bordero" // Use App Group's id here.
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id)!
        return containerURL.appendingPathComponent("Bordero.sqlite")
    }
    
    private init() {
//        DataController.resetAppData()
        self.container = DataController.setupSyncContainer(iCloudIsOn: false) // Charge une premiere fois pour initialiser la description à nul puis le refresh si nécessaire.
        
        updateICloudSettings()
    }
    
    func updateICloudSettings() {
        if DataController.getStatusiCloud() {
            self.container = DataController.setupSyncContainer(iCloudIsOn: true)
        }
    }
    
    static func resetAppData() {
        let appGroupID = "group.com.bigVariable.bordero"
        
        // Supprimer les fichiers du conteneur d'application
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            do {
                let fileManager = FileManager.default
                let filePaths = try fileManager.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: nil, options: [])
                for filePath in filePaths {
                    try fileManager.removeItem(at: filePath)
                }
                print("Tous les fichiers du conteneur d'application ont été supprimés.")
            } catch {
                print("Erreur lors de la suppression des fichiers du conteneur d'application : \(error)")
            }
        }
        
        // Supprimer les fichiers SQLite
        let urls = [
            DataController.sharedStoreURL,
            DataController.sharedStoreURL.appendingPathExtension("shm"),
            DataController.sharedStoreURL.appendingPathExtension("wal")
        ]

        for url in urls {
            do {
                try FileManager.default.removeItem(at: url)
                print("Fichier \(url) supprimé.")
            } catch {
                print("Erreur lors de la suppression de \(url): \(error)")
            }
        }
        
        // Recréer le conteneur sans iCloud
        let _ = DataController.setupSyncContainer(iCloudIsOn: false)
    }
    
    static func getStatusiCloud() -> Bool {
        let iCloudToken = FileManager.default.ubiquityIdentityToken // check si l'utilisateur à activé icloud ou non
        return iCloudToken != nil
    }
    
    static func setupSyncContainer(iCloudIsOn : Bool) -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: "Model")
        
        // 1. Configure for App Group
        let groupIdentifier = "group.com.bigVariable.bordero"
        let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
        let storeDescription = NSPersistentStoreDescription(url: sharedContainerURL!.appendingPathComponent("Model.sqlite")) // Replace with your data model name
        
        // 2. Configure for CloudKit
        let cloudKitContainerIdentifier = "iCloud.com.bigVariable.Bordero" // Replace with your CloudKit container identifier
        let cloudKitOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: cloudKitContainerIdentifier)
        storeDescription.cloudKitContainerOptions = cloudKitOptions
        
        // 3. Handle merges
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // 4. Assign store description
        container.persistentStoreDescriptions = [storeDescription]
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("###\(#function): Failed to retrieve a persistent store description.")
        }
        
        // leave the default cloudKitContainerOptions value as it is, then it will sync automatically
        if !iCloudIsOn {
            description.cloudKitContainerOptions = nil
        }
        
//        description.url = sharedStoreURL
//        
//        
//        
//        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//        let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
//        description.setOption(true as NSNumber,
//                              forKey: remoteChangeKey)
//        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
//        container.viewContext.automaticallyMergesChangesFromParent = true
//        
//        // sets the merge conflict strategy. If this property is not set, Core Data will default to using NSErrorMergePolicy as the conflict resolution strategy (do not handle any conflicts, directly report an error), which will cause iCloud data to not merge correctly into the local database.
//        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        do {
            try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
            fatalError("Failed to pin viewContext to the current generation:\(error)")
        }
        
        return container
    }
    
    static func saveContext() {
        let context = shared.container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                print("Success")
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    static func rollback() {
        let context = shared.container.viewContext
        
        if context.hasChanges {
            context.rollback()
        }
    }
}

public extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
