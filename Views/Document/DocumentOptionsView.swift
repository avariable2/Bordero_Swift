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
    
    @State private var numeroFacture = ""
    @State private var emission = Date()
    @State private var echeance = Date()
    
    @State private var selectedTypeRemise : Remise.TypeRemise = .pourcentage
    @State private var montantDeLaRemise : Double = 0
    
    @State private var carte : Bool
    @State private var especes : Bool
    @State private var virementB : Bool
    @State private var cheque : Bool
    
    @State private var unChangementCoreDataAEuLieu = false
    
    @FetchRequest(sortDescriptors: [], predicate: PraticienUtils.predicate) var praticien : FetchedResults<Praticien>
    
    var viewModel : PDFViewModel
    
    init(viewModel : PDFViewModel) {
        self.viewModel = viewModel
        
        selectedTypeRemise = viewModel.pdfModel.optionsDocument.remise.type
        montantDeLaRemise = viewModel.pdfModel.optionsDocument.remise.montant
        
        carte = viewModel.pdfModel.optionsDocument.payementAllow.contains(Payement.carte)
        especes = viewModel.pdfModel.optionsDocument.payementAllow.contains(Payement.especes)
        virementB = viewModel.pdfModel.optionsDocument.payementAllow.contains(Payement.virement)
        cheque = viewModel.pdfModel.optionsDocument.payementAllow.contains(Payement.cheque)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        FormPraticienView(isOnBoarding: false, praticien: praticien.first)
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
                    DatePickerViewCustom(text: "Date d'émission", selection: $emission)
                        .onChange(of: emission) { oldValue, newValue in
                            viewModel.pdfModel.optionsDocument.dateEmission = newValue
                        }
                    
                    DatePickerViewCustom(text: "Date d'échéance", selection: $echeance)
                        .onAppear {
                            echeance = viewModel.pdfModel.optionsDocument.dateEcheance
                        }
                        .onChange(of: echeance) { oldValue, newValue in
                            viewModel.pdfModel.optionsDocument.dateEcheance = newValue
                        }
                }
                
                Section("Remise sur votre \(viewModel.pdfModel.optionsDocument.estFacture ? "Facture" : "Devis")") {
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
                            TextField("0%", value: $montantDeLaRemise, format: .percent)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        } else {
                            TextField("0,00€", value: $montantDeLaRemise, format: .currency(code: "EUR"))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .onChange(of: montantDeLaRemise) { oldValue, newValue in
                        viewModel.pdfModel.optionsDocument.remise.montant = newValue
                    }
                }
                
                Section("Mode de paiement accepté") {
                    Toggle("Carte", isOn: $carte)
                        .onChange(of: carte) { oldValue, newValue in
                            praticien.first?.carte = newValue
                            
                            unChangementCoreDataAEuLieu = true
                        }
                    
                    Toggle("Espèces", isOn: $especes)
                        .onChange(of: especes) { oldValue, newValue in
                            praticien.first?.espece = newValue
                            
                            unChangementCoreDataAEuLieu = true
                            
                        }
                    
                    Toggle("Virement bancaire", isOn: $virementB)
                        .onChange(of: virementB) { oldValue, newValue in
                            praticien.first?.virement_bancaire = newValue
                            
                            unChangementCoreDataAEuLieu = true
                            
                        }
                    
                    Toggle("Chèque", isOn: $cheque)
                        .onChange(of: cheque) { oldValue, newValue in
                            praticien.first?.cheque = newValue
                            
                            unChangementCoreDataAEuLieu = true
                            
                        }
                    
                }
                .toggleStyle(SwitchToggleStyle(tint: .green))
                
            }
            .navigationTitle("Options document")
            .navigationBarTitleDisplayMode(.large)
            .headerProminence(.increased)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        save()
                        
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("Document")
                        }
                    }
                }
            }
        }
    }
    
    func save() {
        if unChangementCoreDataAEuLieu {
            do {
                try moc.save()
                print("Success")
            } catch let err {
                print("error \(err)")
            }
        }
    }
    
}

#Preview {
    DocumentOptionsView(viewModel: PDFViewModel())
}
