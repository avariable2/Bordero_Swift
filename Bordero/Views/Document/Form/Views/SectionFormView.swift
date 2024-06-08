//
//  SectionFormView.swift
//  Bordero
//
//  Created by Grande Variable on 08/06/2024.
//

import SwiftUI

struct DocumentTypeSection: View {
    @Binding var typeSelected: TypeDoc
    @Binding var viewModel: PDFViewModel
    
    var body: some View {
        Section {
            Picker("Type de document", selection: $typeSelected.animation()) {
                ForEach(TypeDoc.allCases) { type in
                    Text(type.rawValue.capitalized)
                        .font(.title)
                }
            }
            .pickerStyle(.segmented)
            .onAppear {
                typeSelected = viewModel.pdfModel.optionsDocument.estFacture ? .facture : .devis
            }
            .onChange(of: typeSelected) { oldValue, newValue in
                viewModel.pdfModel.optionsDocument.estFacture = newValue == .facture
            }
            
            LabeledContent {
                TextField("obligatoire", text: $viewModel.pdfModel.optionsDocument.numeroDocument)
                    .keyboardType(.default)
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.next)
                    .onSubmit {
                        hideKeyboard()
                    }
                
            } label: {
                ViewThatFits {
                    Text("Numéro de \(typeSelected.rawValue.capitalized):")
                    Text("Numéro")
                    Text("N°")
                }
            }
        }
    }
}

struct ClientSection: View {
    var viewModel: PDFViewModel
    @Binding var activeSheet: ActiveSheet?
    
    var body: some View {
        Section {
            if let client = viewModel.pdfModel.client {
                HStack {
                    ClientRowView(
                        firstname: client.firstname,
                        name: client.lastname
                    )
                    Spacer()
                    Button {
                        withAnimation {
                            viewModel.pdfModel.client = nil
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .symbolRenderingMode(.monochrome)
                            .foregroundStyle(.red)
                    }
                }
            } else {
                Button {
                    activeSheet = .selectClient
                } label: {
                    Label {
                        Text("sélectionner un(e) client(e)")
                            .tint(.primary)
                    } icon: {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(.green)
                    }
                }
            }
        } header: {
            Text("Client")
        }
    }
}

struct TypeActeSection: View {
    @Binding var viewModel: PDFViewModel
    @Binding var activeSheet: ActiveSheet?
    
    var body: some View {
        Section {
            if !viewModel.pdfModel.elements.isEmpty {
                ForEach($viewModel.pdfModel.elements, id: \.self) { snapshot in
                    TypeActeRowView(snapshotTypeActe: snapshot)
                }
                .onDelete { indexSet in
                    viewModel.pdfModel.elements.remove(atOffsets: indexSet)
                }
            }
            
            Button {
                activeSheet = .selectTypeActe
            } label: {
                Label {
                    Text("ajouter un type d'acte")
                        .tint(.primary)
                } icon: {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(.green)
                }
            }
        } header: {
            Text("Prestation(s)")
        } footer: {
            Text("Pour supprimer un élément de la liste, déplacez le sur la gauche.")
        }
    }
}

struct PaymentSection: View {
    @Binding var estPayer: Bool
    @Binding var selectedPayement: Payement
    var viewModel: PDFViewModel
    
    var body: some View {
        Section("Réglement") {
            Toggle("Facture déjà réglée ?", isOn: $estPayer.animation())
                .toggleStyle(SwitchToggleStyle(tint: .green))
            
            if estPayer {
                ViewThatFits {
                    Picker("Mode de paiement", selection: $selectedPayement) {
                        ForEach(Payement.allCases) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Mode de paiement")
                        Picker("", selection: $selectedPayement) {
                            ForEach(Payement.allCases) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                        .padding(.bottom)
                    }
                }
            }
        }
        .onChange(of: estPayer) { oldValue, newValue in
            viewModel.pdfModel.optionsDocument.payementFinish = newValue
        }
        .onChange(of: selectedPayement) { oldValue, newValue in
            viewModel.pdfModel.optionsDocument.payementUse = newValue
        }
    }
}

struct NoteSection: View {
    @Binding var notes: String
    
    var body: some View {
        Section {
            TextEditor(text: $notes)
                .lineSpacing(3)
        } header: {
            Text("Note")
        }
    }
}

struct TypeActeRowView: View {
    @Binding var snapshotTypeActe: SnapshotTypeActe
    @State private var showSheet = false
    
    var body: some View {
        Button {
            showSheet.toggle()
        } label: {
            Label {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(snapshotTypeActe.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        Button {
                            withAnimation {
                                showSheet.toggle()
                            }
                        } label: {
                            Image(systemName: "info.circle.fill")
                                .symbolRenderingMode(.monochrome)
                                .foregroundStyle(.blue)
                        }
                    }
                    LabeledContent("Quantité", value: snapshotTypeActe.quantity, format: .number)
                        .foregroundStyle(.secondary)
                    LabeledContent("Prix", value: snapshotTypeActe.price, format: .currency(code: "EUR"))
                        .foregroundStyle(.secondary)
                    if !Calendar.current.isDateInToday(snapshotTypeActe.date) {
                        LabeledContent("Date", value: snapshotTypeActe.date.formatted(.dateTime.day().month().year()))
                            .foregroundStyle(.secondary)
                    }
                    if !snapshotTypeActe.remarque.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Remarques :")
                                .foregroundStyle(.secondary)
                            Text("«")
                            +
                            Text(snapshotTypeActe.remarque)
                                .foregroundStyle(.secondary)
                            +
                            Text("»")
                        }
                    }
                }
                .tint(.primary)
            } icon: {
                Image(systemName: "cross.case.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(.white, .purple)
            }
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                TypeActeOptionsView(snapshotTypeActe: $snapshotTypeActe)
            }
        }
    }
}

struct TypeActeOptionsView: View {
    @Binding var snapshotTypeActe: SnapshotTypeActe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Quantité")
                .font(.caption)
                .foregroundStyle(.secondary)
            Stepper(
                value: $snapshotTypeActe.quantity,
                in: 0...100
            ) {
                Text(snapshotTypeActe.quantity, format: .number)
            }
        }
        DatePicker("Date de l'acte", selection: $snapshotTypeActe.date, displayedComponents: .date)
        VStack(alignment: .leading, spacing: 2) {
            Text("Remarques")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextEditor(text: $snapshotTypeActe.remarque)
                .lineSpacing(2)
                .keyboardType(.default)
                .multilineTextAlignment(.leading)
                .padding(2)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.tertiary, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
        .navigationTitle("Options de \(snapshotTypeActe.name)")
        .presentationDetents([.fraction(0.3), .medium])
    }
    
}

struct FormButtonsPrimaryActionView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) private var dismiss
    
    @Binding var activeSheet: ActiveSheet?
    @Binding var viewModel: PDFViewModel
    
    @State private var showDetail = false
    @State private var detailDocument: Document?
    
    @State private var launchSauvegarde: Bool = false
    
    private var userDontAddClient: Bool {
        viewModel.pdfModel.client == nil
    }
    
    var body: some View {
        ViewThatFits {
            HStack {
                SaveButton(launchSauvegarde: $launchSauvegarde, viewModel: viewModel)
                Spacer()
                Button {
                    activeSheet = .apercusDocument
                } label: {
                    Label("Aperçu", systemImage: "eyeglasses")
                }
                .buttonStyle(.bordered)
            }
            VStack {
                SaveButton(launchSauvegarde: $launchSauvegarde, viewModel: viewModel)
                    .padding(.bottom)
                Button {
                    activeSheet = .apercusDocument
                } label: {
                    Label("Aperçu", systemImage: "eyeglasses")
                }
                .buttonStyle(.bordered)
            }
        }
        .task(id: launchSauvegarde) {
            guard launchSauvegarde else { return }
            await viewModel.finalizeAndSave { document in
                if viewModel.documentObject == nil {
                    self.detailDocument = document
                    self.showDetail = true
                } else {
                    dismiss()
                }
            }
            launchSauvegarde = false
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .navigationDestination(isPresented: $showDetail) {
            if let document = detailDocument {
                DocumentDetailView(document: document)
            }
        }
    }
}

struct SaveButton: View {
    @Binding var launchSauvegarde: Bool
    var viewModel: PDFViewModel
    
    var body: some View {
        Button {
            launchSauvegarde.toggle()
            AnalyticsService.shared.track(event: .documentCreated, category: .documentManagement)
        } label: {
            Label {
                Text("Sauvegarder")
                    .fixedSize()
            } icon: {
                Image(systemName: "square.and.arrow.down")
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.pdfModel.client == nil)
    }
}

struct SheetView: View {
    var activeSheet: ActiveSheet
    var viewModel: PDFViewModel
    
    var body: some View {
        NavigationStack {
            switch activeSheet {
            case .apercusDocument:
                PDFDisplayView(viewModel: viewModel)
                    .presentationDetents([.large])
            case .selectClient:
                ListClients(callbackClientClick: { client in
                    viewModel.pdfModel.client = client
                })
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            // Close sheet
                        } label: {
                            Text("Retour")
                        }
                    }
                }
            case .selectTypeActe:
                ListTypeActe { type in
                    let snapshot = type.getSnapshot(date: Date(), quantite: 1, remarque: "")
                    viewModel.pdfModel.elements.append(snapshot)
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            // Close sheet
                        } label: {
                            Text("Retour")
                        }
                    }
                }
            default:
                EmptyView()
            }
        }
    }
}

private extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    DocumentFormView()
}

