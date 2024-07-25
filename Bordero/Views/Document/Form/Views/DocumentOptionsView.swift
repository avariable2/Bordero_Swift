//
//  DetailFormView.swift
//  Bordero
//
//  Created by Grande Variable on 13/02/2024.
//

import SwiftUI

struct DocumentOptionsView: View, Saveable {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTypeRemise : Remise.TypeRemise = .pourcentage
    
    @State private var carte : Bool = false
    @State private var especes : Bool = false
    @State private var virementB : Bool = false
    @State private var cheque : Bool = false
    
    @FetchRequest(sortDescriptors: [], predicate: PraticienUtils.predicate) var praticien : FetchedResults<Praticien>
    
    @Bindable var viewModel : PDFViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        if let praticien = praticien.first {
                            FormPraticienView(praticien: praticien)
                        }
                    } label: {
                        RowIconColor(
                            text: "Vos informations",
                            systemName: "person.crop.square.fill",
                            color: .pink,
                            accessibility: "Bouton pour modifier vos informations"
                        )
                    }
                }
                
                Section {
                    DatePickerViewCustom(text: "Date d'émission", selection: $viewModel.pdfModel.optionsDocument.dateEmission)
                    
                    DatePickerViewCustom(text: "Date d'échéance", selection: $viewModel.pdfModel.optionsDocument.dateEcheance)
                        .onAppear {
                            if let praticien = praticien.first {
                                viewModel.pdfModel.optionsDocument.dateEcheance =
                                Calendar.current.date(byAdding: .day, value: Int(praticien.defaultRangeDateEcheance_), to: Date()) ?? Date()
                            }
                        }
                }
                
                Section("Remise sur votre \(viewModel.pdfModel.optionsDocument.estFacture ? "facture" : "devis")") {
                    Picker("Type de remise", selection: $selectedTypeRemise) {
                        ForEach(Remise.TypeRemise.allCases) { option in
                            Text(String(describing: option))
                        }
                    }
                    .onChange(of: selectedTypeRemise) { oldValue, newValue in
                        viewModel.pdfModel.optionsDocument.remise.type = newValue
                    }
                    
                    LabeledContent("Montant de remise") {
                        if selectedTypeRemise == .pourcentage {
                            TextField("0%", value: $viewModel.pdfModel.optionsDocument.remise.montant, format: .percent)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        } else {
                            TextField("0,00€", value: $viewModel.pdfModel.optionsDocument.remise.montant, format: .currency(code: "EUR"))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                
                Section("Modes de paiement acceptés") {
                    Toggle("Carte", isOn: $carte)
                        .onChange(of: carte) { oldValue, newValue in
                            praticien.first?.carte = newValue
                            
                            viewModel.modifyPayementAllow(.carte, value: newValue)
                        }
                    
                    Toggle("Espèces", isOn: $especes)
                        .onChange(of: especes) { oldValue, newValue in
                            praticien.first?.espece = newValue
                            
                            viewModel.modifyPayementAllow(.especes, value: newValue)
                        }
                    
                    Toggle("Virement bancaire", isOn: $virementB)
                        .onChange(of: virementB) { oldValue, newValue in
                            praticien.first?.virement_bancaire = newValue
                            
                            viewModel.modifyPayementAllow(.virement, value: newValue)
                        }
                    
                    Toggle("Chèque", isOn: $cheque)
                        .onChange(of: cheque) { oldValue, newValue in
                            praticien.first?.cheque = newValue
                            
                            viewModel.modifyPayementAllow(.cheque, value: newValue)
                        }
                    
                }
                .toggleStyle(SwitchToggleStyle(tint: .green))
                
            }
            .navigationTitle("Options document")
            .navigationBarTitleDisplayMode(.large)
            .headerProminence(.increased)
            .onAppear() {
                selectedTypeRemise = viewModel.pdfModel.optionsDocument.remise.type
                
                let options = viewModel.pdfModel.optionsDocument
                if !options.payementAllow.isEmpty {
                    carte = options.payementAllow.contains(Payement.carte)
                    especes = options.payementAllow.contains(Payement.especes)
                    virementB = options.payementAllow.contains(Payement.virement)
                    cheque = options.payementAllow.contains(Payement.cheque)
                } else {
                    if let praticien = praticien.first {
                        carte = praticien.carte
                        especes = praticien.espece
                        virementB = praticien.virement_bancaire
                        cheque = praticien.cheque
                    }
                }
            }
            .onDisappear() {
                save()
            }
        }
    }
    
    func save() {
        DataController.saveContext()
    }
    
}

#Preview {
    DocumentOptionsView(viewModel: PDFViewModel())
}
