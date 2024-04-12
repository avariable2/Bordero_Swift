//
//  DetailFormView.swift
//  Bordero
//
//  Created by Grande Variable on 13/02/2024.
//

import SwiftUI

struct FormOptionsView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State private var numeroFacture = ""
    @State private var emission = Date()
    @State private var echeance = Date()
    
    @State private var selectedTypeRemise : Remise.TypeRemise = .pourcentage
    @State private var remise : Decimal = 0
    
    @State private var carte : Bool = true
    @State private var especes : Bool = true
    @State private var virementB : Bool = true
    @State private var cheque : Bool = true
    
    @FetchRequest(sortDescriptors: []) var praticien : FetchedResults<Praticien>
    
    var viewModel : PDFViewModel
    
//    private lazy var format: FormatStyle.Type = {
//        switch selectedTypeRemise {
//        case .pourcentage:
//            return Decimal.FormatStyle.Percent // Exemple avec aucune décimale
//        case .montantFixe:
//            return Decimal.FormatStyle.Currency(code: "EUR")// Exemple avec deux décimales
//        }
//    }()
    
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
                            viewModel.documentData.optionsDocument.dateCreated = newValue
                        }
                    
                    DatePickerViewCustom(text: "Date d'échéance", selection: $echeance)
                        .onAppear {
                            echeance = addOrSubtractMonth(day: 30)
                        }
                        .onChange(of: echeance) { oldValue, newValue in
                            viewModel.documentData.optionsDocument.dateEcheance = newValue
                        }
                }
                
                Section("Remise sur votre facture") {
                    Picker("Type de remise", selection: $selectedTypeRemise) {
                        ForEach(Remise.TypeRemise.allCases) { option in
                            Text(String(describing: option))
                        }
                    }
                    .onChange(of: selectedTypeRemise) { oldValue, newValue in
                        viewModel.documentData.optionsDocument.remise.type = newValue
                    }
                    
                    LabeledContent("Montant de remise") {
                        if selectedTypeRemise == .pourcentage {
                            TextField("0%", value: $remise, format: .percent)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        } else {
                            TextField("0,00€", value: $remise, format: .currency(code: "EUR"))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .onChange(of: remise) { oldValue, newValue in
                        viewModel.documentData.optionsDocument.remise.montant = newValue
                    }
                }
                
                Section("Mode de paiement accepté") {
                    Toggle("Carte", isOn: $carte)
                    Toggle("Espèces", isOn: $especes)
                    Toggle("Virement bancaire", isOn: $virementB)
                    Toggle("Chèque", isOn: $cheque)
                }
                .toggleStyle(SwitchToggleStyle(tint: .green))
                
            }
            .navigationTitle("Options document")
            .navigationBarTitleDisplayMode(.large)
            .headerProminence(.increased)
        }
    }
    
    func addOrSubtractMonth(day: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: day, to: Date())!
    }
    
}

#Preview {
    FormOptionsView(viewModel: PDFViewModel())
}
