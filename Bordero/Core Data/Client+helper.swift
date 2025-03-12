//
//  Client+helper.swift
//  Bordero
//
//  Created by Grande Variable on 10/04/2024.
//

import Foundation
import CoreData

extension Client {
    
    var firstname : String {
        get { firstname_ ?? "" }
        set { firstname_ = newValue }
    }
    
    var lastname : String {
        get { name_ ?? "" }
        set { name_ = newValue }
    }
    
    var email : String {
        get { email_ ?? "" }
        set { email_ = newValue }
    }
    
    var phone : String {
        get { phone_ ?? "" }
        set { phone_ = newValue }
    }
    
    var listDocuments : Set<Document> {
        get { documents_ as? Set<Document> ?? [] }
        set { documents_ = newValue as NSSet }
    }
    
    var listPaiements : Set<Paiement> {
        get { paiements_ as? Set<Paiement> ?? [] }
    }
    
    var siret : String {
        get { siret_ ?? "" }
        set { siret_ = newValue }
    }
    
    var siren : String {
        get { siren_ ?? "" }
        set { siren_ = newValue }
    }
    
    func getAdresseSurUneLigne(_ adresse : [String : Any]?) -> String {
        if let coordonne = adresse {
            return PDFUtils.getRowAdresse(
                coordonne
            ).formatted(.list(type: .and, width: .narrow))
        }
        return ""
    }
    
    func getFullName() -> String {
        return "\(self.firstname) \(self.lastname)"
    }
    
    var nameUppercaseWithFirstNameCapitalized : String {
        return "\(lastname.uppercased()) \(firstname.capitalized)"
    }
    
    convenience init(
        firstname : String,
        lastname : String,
        phone : String,
        email : String,
        context : NSManagedObjectContext) {
            self.init(context: context)
            self.firstname = firstname
            self.lastname = lastname
            self.phone  = phone
            self.email = email
    }
    
    public override func awakeFromInsert() {
        self.id = UUID()
    }
    
    static func delete(client : Client) {
        guard let context = client.managedObjectContext else { return }
        
        context.delete(client)
    }
    
    static func fetch(_ predicate : NSPredicate = .all) -> NSFetchRequest<Client> {
        let request = Client.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Client.name_, ascending: true)]
        request.predicate = predicate
        
        return request
    }
    
    static var example : Client {
        let context = DataController.shared.container.viewContext
        let client = Client(firstname: "Ad", lastname: "VORY", phone: "0102030405", email: "ad.vory@gmail.com", context: context)
        
        client.listDocuments.insert(Document.example)
        return client
    }
    
}
