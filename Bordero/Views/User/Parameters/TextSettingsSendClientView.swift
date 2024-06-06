//
//   TextSettingsendClientView.swift
//  Bordero
//
//  Created by Grande Variable on 20/05/2024.
//

import SwiftUI

struct TextSettingsSendClientView : View {
    @Environment(\.dismiss) var dismiss
    @State var praticien : Praticien
    
    @State private var showCommande = true
    
    @State private var titreFacture = "Facture #NUMERO#"
    @State private var bodyMessageFacture = """
Bonjour #NOM_CLIENT#,

Voici votre facture du #DATE_DOCUMENT#.

Cordialement,
#NOM_SOCIETE#
"""
    
    @State private var titreDevis = "Devis #NUMERO#"
    @State private var bodyMessageDevis = """
Bonjour #NOM_CLIENT#,

Voici votre devis du #DATE_DOCUMENT#.

Cordialement,
#NOM_SOCIETE#
"""
    
    var body: some View {
        VStack {
            List {
                DisclosureGroup("Vous pouvez personnaliser votre message lors de l'envoi des documents. Voici les balises que vous pouvez utiliser : ", isExpanded: $showCommande) {
                    
                    
                    RowCommandeView(titre: "Prix total", commande: "#TOTAL#")
                    RowCommandeView(titre: "Date création document", commande: "#DATE_DOCUMENT#")
                    RowCommandeView(titre: "Nom du document", commande: "#NOM_DOCUMENT#")
                    RowCommandeView(titre: "Numéro du document", commande: "#NUMERO#")
                    RowCommandeView(titre: "Nom du client", commande: "#NOM_CLIENT#")
                    RowCommandeView(titre: "Nom de l'entreprise", commande: "#NOM_SOCIETE#")
//                    RowCommandeView(titre: "Personne à contacter", commande: "#CONTACT_SOCIETE#")
                    
                }
                
                Section("Facture") {
                    TextField("Titre du message pour une facture", text: $titreFacture)
                        .keyboardType(.default)
                    
                    TextEditor(text: $bodyMessageFacture)
                        .keyboardType(.default)
                        .frame(minHeight: 200)
                        .accessibilityLabel("Corps du message pour la facture")
                }
                
                Section("Devis") {
                    TextField("Titre du message pour un devis", text: $titreDevis)
                        .keyboardType(.default)
                    
                    TextEditor(text: $bodyMessageDevis)
                        .keyboardType(.default)
                        .frame(minHeight: 200)
                        .accessibilityLabel("Corps du message pour le devis")
                }
            }
            .onAppear {
                retrieveData()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        save()
                    } label: {
                        Text("Sauvegarder")
                    }
                }
            }
        }
        
    }
    
    func save() {
        praticien.structMessageFacture = Praticien.MessageBody(titre: titreFacture, corps: bodyMessageFacture)
        praticien.structMessageDevis = Praticien.MessageBody(titre: titreDevis, corps: bodyMessageDevis)
        
        DataController.saveContext()
        dismiss()
    }
    
    func retrieveData() {
        titreFacture = praticien.structMessageFacture.titre
        bodyMessageFacture = praticien.structMessageFacture.corps
        
        titreDevis = praticien.structMessageDevis.titre
        bodyMessageDevis = praticien.structMessageDevis.corps
    }
}

#Preview {
    TextSettingsSendClientView(praticien: Praticien.example)
}

private struct RowCommandeView : View {
    let titre : String
    let commande : String
    
    var body: some View {
        LabeledContent(titre) {
            Text(commande)
                .foregroundStyle(.link)
        }
    }
}
