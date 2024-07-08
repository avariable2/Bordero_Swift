//
//  Praticien+helper.swift
//  Bordero
//
//  Created by Grande Variable on 27/02/2024.
//

import Foundation
import CoreData

extension Praticien {
    struct MessageBody {
        var titre : String
        var corps : String
    }
    
    struct ParametersModele {
        var showDateEcheance : Bool
        var showModePaiement : Bool
    }
    
    var firstname : String {
        get { firstname_ ?? "" }
        set { firstname_ = newValue }
    }
    
    var lastname : String {
        get { lastname_ ?? "" }
        set { lastname_ = newValue }
    }
    
    var phone : String {
        get { phone_ ?? "" }
        set { phone_ = newValue }
    }
    
    var email : String {
        get { email_ ?? "" }
        set { email_ = newValue }
    }
    
    var website : String {
        get { website_ ?? "" }
        set { website_ = newValue }
    }
    
    var siret : String {
        get { siret_ ?? "" }
        set { siret_ = newValue }
    }
    
    var adeli : String {
        get { adeli_ ?? "" }
        set { adeli_ = newValue }
    }
    
    var nomEntreprise : String {
        get { nom_proffession ?? "" }
        set { nom_proffession = newValue }
    }
    
    var paramsDocument : ParametersModele {
        get {
            ParametersModele(
                showDateEcheance: parametersDocument_?["showDateEcheance"] as? Bool ?? true,
                showModePaiement: parametersDocument_?["showModePaiement"] as? Bool ?? true
            )
        }
        set {
            parametersDocument_ = [
                "showDateEcheance" : newValue.showDateEcheance,
                "showModePaiement" : newValue.showModePaiement
            ]
        }
    }
    
    var structMessageFacture : MessageBody {
        get {
            MessageBody(
                titre: structureMessageFacture?["titre"] as? String ?? "",
                corps: structureMessageFacture?["corps"] as? String ?? ""
            )
        }
        set {
            structureMessageFacture = [
                "titre" : newValue.titre,
                "corps" : newValue.corps
            ]
        }
    }
    
    var structMessageDevis : MessageBody {
        get {
            MessageBody(
                titre: structureMessageDevis?["titre"] as? String ?? "",
                corps: structureMessageDevis?["corps"] as? String ?? ""
            )
        }
        set {
            structureMessageDevis = [
                "titre" : newValue.titre,
                "corps" : newValue.corps
            ]
        }
    }
    
    var hasAcceptNotification : Bool {
        get {
            parametersNotifications_?["acceptNotification"] as? Bool ?? false
        }
        set {
            parametersNotifications_ = [
                "acceptNotification" : newValue
            ]
        }
    }
    
    func getAdresseSurUneLigne() -> String {
        if let coordonne = self.adresse1 {
            return PDFUtils.getTableauInfoAdresse(
                coordonne["etage_appt"] as? String,
                coordonne["rue"] as? String,
                (coordonne["code_postal"] as? Int32)?.description,
                coordonne["ville"] as? String
            ).formatted(.list(type: .and, width: .narrow))
        }
        return ""
    }
    
    convenience init(
        moc : NSManagedObjectContext
    ) {
        self.init(context: moc)
        self.id = UUID(uuidString: "62094590-C187-4F68-BE0D-D8E348299900")
        self.defaultRangeDateEcheance_ = Int16(DateEcheanceParams.trente.value)
        self.structureMessageDevis = [
            "titre" : "Devis #NUMERO#",
            "corps" : """
Bonjour #NOM_CLIENT#,

Voici votre devis du #DATE_DOCUMENT#.

Cordialement,
#NOM_SOCIETE#
"""
        ]
        self.structureMessageFacture = [
            "titre" : "Facture #NUMERO#",
            "corps" : """
Bonjour #NOM_CLIENT#,

Voici votre facture du #DATE_DOCUMENT#.

Cordialement,
#NOM_SOCIETE#
"""
        ]
    }
    
    convenience init(
        firstname : String,
        lastname : String,
        phone : String,
        email : String,
        website : String,
        siret : String,
        adeli : String,
        context : NSManagedObjectContext) {
            self.init(context: context)
            self.firstname = firstname
            self.lastname = lastname
            self.phone  = phone
            self.email = email
            self.website = website
            self.siret = siret
            self.adeli = adeli
    }
    
    static var example : Praticien {
        let praticien = Praticien(firstname: "Ad", lastname: "Vori", phone: "01.02.03.04.05", email: "example@miid.fr", website: "ww.google.com", siret: "0102010201", adeli: "01001020102", context: DataController.shared.container.viewContext)
        return praticien
    }
}
