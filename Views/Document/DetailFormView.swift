//
//  DetailFormView.swift
//  Bordero
//
//  Created by Grande Variable on 13/02/2024.
//

import SwiftUI

struct DetailFormView: View {
    enum TypeRemise: CaseIterable, Identifiable, CustomStringConvertible {
        case pourcentage
        case montantFixe
        
        var id: Self { self }
        var description: String {
            switch self {
            case .pourcentage:
                return "Pourcentage"
            case .montantFixe:
                return "Montant Fixe"
            }
        }
    }
    
    @State private var numeroFacture = ""
    @State private var emission = Date()
    @State private var echeance = Date()
    
    @State private var selectedTypeRemise : TypeRemise = .pourcentage
    @State private var remise = ""
    
    @State private var carte : Bool = true
    @State private var especes : Bool = true
    @State private var virementB : Bool = true
    @State private var cheque : Bool = true
    
    
    var body: some View {
        Form {
            Section {
                LabeledContent("N° facture") {
                    TextField("001", text: $numeroFacture)
                }
                LabeledContent("Date d'émission") {
                    DatePicker("",
                        selection: $emission,
                        displayedComponents: .date
                    )
                }
                LabeledContent("Date d'échéance") {
                    DatePicker("",
                        selection: $echeance,
                        displayedComponents: .date
                    )
                }
            }
            
            Section("Remise sur votre facture") {
                Picker("Type de remise", selection: $selectedTypeRemise) {
                    ForEach(TypeRemise.allCases) { option in
                        Text(String(describing: option))
                    }
                }
                LabeledContent("Montant de remise") {
                    TextField("0,00%", text: $remise)
                }
            }
            
            Section("Mode de paiement") {
                Toggle("Carte", isOn: $carte)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                Toggle("Espèces", isOn: $especes)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                Toggle("Virement bancaire", isOn: $virementB)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                Toggle("Chèque", isOn: $cheque)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            }
            
            Section {
                
            }
        }
    }
}

#Preview {
    DetailFormView()
}
