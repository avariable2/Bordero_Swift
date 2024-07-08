//
//  ModeleDocumentView.swift
//  Bordero
//
//  Created by Grande Variable on 21/03/2024.
//

import SwiftUI

enum DateEcheanceParams : String, CaseIterable, Identifiable {
    case zero = "0 jour",
         sept = "7 jours",
         quatorze = "14 jours",
         vingtEtUn = "21 jours",
         trente = "30 jours",
         quanranteCinq = "45 jours",
         soixante = "60 jours",
         quatreVingtDix = "90 jours"
    var id : Self { self }
    
    var value : Int {
        switch self {
        case .zero:
            0
        case .sept:
            7
        case .quatorze:
            14
        case .vingtEtUn:
            21
        case .trente:
            30
        case .quanranteCinq:
            45
        case .soixante:
            60
        case .quatreVingtDix:
            90
        }
    }
    
    static func from(value: Int) -> DateEcheanceParams? {
        return self.allCases.first { $0.value == value }
    }
}

struct ModeleDocumentView: View {
    @Environment(\.dismiss) var dismiss
    @State var praticien : Praticien
    
    @State private var color: Color = .green
    @State private var dateEcheanceDefaut : DateEcheanceParams = .trente
    
    var body: some View {
        VStack {
            Form {
                Section {
                    ColorPicker("Couleur des documents", selection: $color, supportsOpacity: false)
                        .foregroundStyle(.secondary)
                        .disabled(true)
                    
                    NavigationLink("Modèle de facture") {
                        EmptyView()
                    }
                    .disabled(true)
                } header: {
                    
                } footer: {
                    Text("🏗️ En construction. Disponible dans une future mise à jour.")
                }
                
                Section {
                    Toggle(isOn: $praticien.paramsDocument.showDateEcheance) {
                        Text("Afficher la date d'échéance")
                    }
                    
                    Toggle(isOn: $praticien.paramsDocument.showModePaiement) {
                        Text("Afficher les modes de paiement")
                    }
                    
                    
                }
                
                Section {
                    Picker("Date d'échéance", selection: $dateEcheanceDefaut) {
                        ForEach(DateEcheanceParams.allCases) { echeance in
                            Text(echeance.rawValue).tag(echeance)
                        }
                    }
                    .onAppear {
                        dateEcheanceDefaut = DateEcheanceParams.from(value: Int(praticien.defaultRangeDateEcheance_)) ?? .trente
                    }
                    .onChange(of: dateEcheanceDefaut) { oldValue, newValue in
                        praticien.defaultRangeDateEcheance_ = Int16(newValue.value)
                    }
                    
                    Toggle("Carte", isOn: $praticien.carte)
                    
                    Toggle("Espèces", isOn: $praticien.espece)
                    
                    Toggle("Virement bancaire", isOn: $praticien.virement_bancaire)
                    
                    Toggle("Chèque", isOn: $praticien.cheque)
                } header: {
                   Text("Paramètres prédéfinis")
                } footer : {
                    Text("Sélectionner les informations prédéfinies pour quelles soient automatiquement préremplies lors de la création d'un document.")
                }
                .toggleStyle(SwitchToggleStyle(tint: .green))
            }
        }
        .navigationTitle("Conception du modèle")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    save()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
    
    func save() {
        DataController.saveContext()
    }
}

#Preview {
    ModeleDocumentView(praticien: Praticien.example)
}
