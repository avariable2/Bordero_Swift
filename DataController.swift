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

enum StateCheckiCloud {
    case isLoading
    case notConnected
    case connected
}

@Observable class DataController {
    var accountAvailable : StateCheckiCloud = .isLoading
    var error : String = ""
    
    let container = NSPersistentCloudKitContainer(name: "Model")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load : \(error.localizedDescription)")
            }
        }
        
        checkAccountStatus()
    }
    
    func checkAccountStatus() {
       CKContainer.default().accountStatus { status, error in
         DispatchQueue.main.async {
           switch status {
           case .available:
               self.accountAvailable = .connected
           default:
               self.accountAvailable = .notConnected
           }
           if let error = error {
               print(error)
           }
         }
       }
   }
    
    
}
