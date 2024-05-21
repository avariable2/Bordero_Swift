//
//  UseriCloudController.swift
//  Bordero
//
//  Created by Grande Variable on 23/02/2024.
//

import Foundation
import CloudKit
import Observation

@Observable class UseriCloudController {
    enum StateCheckiCloud {
        case isLoading
        case notConnected
        case connected
    }
    
    var accountAvailable : StateCheckiCloud = .isLoading
    
    init() {
        accountAvailable = .isLoading
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
