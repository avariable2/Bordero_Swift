//
//  FormDocumentView.swift
//  Bordero
//
//  Created by Grande Variable on 12/02/2024.
//

import SwiftUI

struct DocumentFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var praticien: FetchedResults<Praticien>
    
    // MARK: - Versionning des possibles mise a jour de l'entity
    static func getVersion() -> Int32 {
        return 1
    }
    
    private var viewModel : PDFViewModel
    
    init() {
        self.viewModel = PDFViewModel()
    }
    
    var body: some View {
        ModifierDocumentView(viewModel: viewModel)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        viewModel.reset()
                        dismiss()
                    } label: {
                        withAnimation {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Retour")
                            }
                        }
                    }
                    
                }
            }
            .task {
                viewModel.documentData.praticien = praticien.first
                
                // MARK: Reinitialise le tableau pour s'adapter au changement de l'utilisateur
                viewModel.documentData.optionsDocument.payementAllow.removeAll()
                if let cheque = praticien.first?.cheque, cheque == true {
                    viewModel.documentData.optionsDocument.payementAllow.append(Payement.cheque)
                }
                
                if let carte = praticien.first?.carte, carte == true {
                    viewModel.documentData.optionsDocument.payementAllow.append(Payement.carte)
                }
                
                if let virement = praticien.first?.virement_bancaire, virement == true {
                    viewModel.documentData.optionsDocument.payementAllow.append(Payement.virement)
                }
                
                if let espece = praticien.first?.espece, espece == true {
                    viewModel.documentData.optionsDocument.payementAllow.append(Payement.especes)
                }
                
            }
    }
}

struct ModifierDocumentView: View, Versionnable {
    static func getVersion() -> Int32 {
        return 1
    }
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var moc
    
    @State var viewModel : PDFViewModel
    
    @State private var activeSheet: ActiveSheet?
    
    @State private var client : Client? = nil
    @State private var listSnapshotTypeActes = [SnapshotTypeActe]()
    
    @State private var docIsFacture: Bool = true
    @State private var estPayer: Bool = false
    @State private var selectedPayement : Payement = .carte
    @State private var notes: String = ""
    @State private var typeSelected : TypeDoc = .facture
    
    @State var numero : String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type de document", selection: $typeSelected.animation()) {
                        ForEach(TypeDoc.allCases) { type in
                            Text(type.rawValue.capitalized)
                                .font(.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: typeSelected) { oldValue, newValue in
                        viewModel.documentData.optionsDocument.typeDocument = newValue
                    }
                    
                    LabeledContent {
                        TextField("obligatoire", text: $numero.animation())
                            .multilineTextAlignment(.trailing)
                            .onChange(of: numero) { oldValue, newValue in
                                viewModel.documentData.optionsDocument.numeroDocument = newValue
                            }
                    } label : {
                        ViewThatFits {
                            Text("Numéro de \(typeSelected.rawValue.capitalized):")
                            Text("Numéro")
                            Text("N°")
                        }
                    }
                }
                
                Section {
                    if let client = client {
                        HStack {
                            ClientRowView(
                                firstname: client.firstname,
                                name: client.lastname
                            )
                            
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    self.client = nil
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
                                Text("séléctioner un(e) client(e)")
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
                .onChange(of: client) { oldValue, newValue in
                    viewModel.documentData.client = newValue
                }
                
                // MARK: - Partie type Acte
                Section {
                    if !listSnapshotTypeActes.isEmpty {
                        ForEach(listSnapshotTypeActes.indices, id: \.self) { index in
                            TypeActeRowView(snapshotTypeActe: $listSnapshotTypeActes[index])
                        }
                        .onDelete { indexSet in
                            listSnapshotTypeActes.remove(atOffsets: indexSet)
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
                } header : {
                    Text("Préstation(s)")
                } footer : {
                    Text("Pour supprimer un élément de la liste, déplacé le sur la gauche.")
                }
                .onChange(of: listSnapshotTypeActes) { oldValue, newValue in
                    viewModel.documentData.elements = newValue
                }
                
                if typeSelected == .facture {
                    Section("Réglement") {
                        Toggle("Facture déjà réglée ?", isOn: $estPayer.animation())
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                        
                        if estPayer {
                            ViewThatFits {
                                Picker("Mode de paiement", selection: $selectedPayement){
                                    ForEach(Payement.allCases) {
                                        Text($0.rawValue).tag($0)
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Mode de paiement")
                                    Picker("", selection: $selectedPayement){
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
                        viewModel.documentData.optionsDocument.payementFinish = newValue
                    }
                    .onChange(of: selectedPayement) { oldValue, newValue in
                        viewModel.documentData.optionsDocument.payementUse = newValue
                    }
                }
                
                Section {
                    TextEditor(text: $notes)
                        .lineSpacing(3)
                } header: {
                    Text("Note")
                }
                .onChange(of: notes) { oldValue, newValue in
                    viewModel.documentData.optionsDocument.note = newValue
                }
            }
            .safeAreaInset(edge: .bottom) {
                NavigationStack {
                    FormButtonsPrimaryActionView(
                        activeSheet: $activeSheet,
                        viewModel: $viewModel
                    )
                }
                
            }
        }
        .navigationTitle("Document")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Options") {
                    DocumentOptionsView(viewModel: viewModel)
                }
            }
        }
        .sheet(item: $activeSheet) { item in
            NavigationStack {
                switch item {
                case .apercusDocument:
                    PDFDisplayView(viewModel: self.viewModel)
                        .presentationDetents([.large])
                case .selectClient:
                    ListClients(callbackClientClick: { client in
                        self.client = client
                    })
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                activeSheet = nil
                            } label: {
                                Text("Retour")
                            }
                            
                        }
                    }
                case .selectTypeActe:
                    ListTypeActe { type in
                        let snapshot = type.getSnapshot(date: Date(), quantite: 1, remarque: "")
                        listSnapshotTypeActes.append(snapshot)
                    }
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                activeSheet = nil
                            } label: {
                                Text("Retour")
                            }
                            
                        }
                    }
                default:
                    EmptyView() // IMPOSSIBLE
                }
            }
            
        }
    }
}

private struct ClientRowView: View {
    let firstname : String
    let name : String
    
    var body: some View {
        Label {
            VStack {
                Text(firstname)
                + Text(" ")
                + Text(name)
                    .bold()
            }
        } icon: {
            ProfilImageView(imageData: nil)
        }
    }
}

private struct TypeActeRowView: View {
    @Binding var snapshotTypeActe : SnapshotTypeActe
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
                            Text("Remarque :")
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
            } icon : {
                Image(systemName: "cross.case.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(.white, .purple)
            }
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
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
                    Text("Remarque")
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
                
            }
            .padding()
            .navigationTitle("Option de \(snapshotTypeActe.name)")
            .presentationDetents([.fraction(0.3), .medium])
        }
    }
}

struct FormButtonsPrimaryActionView: View {
    @Binding var activeSheet : ActiveSheet?
    @Binding var viewModel : PDFViewModel
    
    @State private var showDetail = false
    @State private var detailDocument : Document?
    
    private var userDontAddClient : Bool {
        viewModel.documentData.client == nil
    }
    
    var body: some View {
        ViewThatFits {
            HStack {
                Button {
                    Task {
                        await viewModel.finalizeAndSave { document in
                            showDetail = true
                            detailDocument = document
                        }
                    }
                } label: {
                    Label {
                        Text("Sauvegarder")
                            .fixedSize()
                    } icon: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(userDontAddClient)
                
                Spacer()
                
                Button {
                    activeSheet = .apercusDocument
                } label: {
                    Label("Aperçus", systemImage: "eyeglasses")
                }
                .buttonStyle(.bordered)
                
            }
            
            VStack {
                Button {
                    Task {
                        await viewModel.finalizeAndSave { document in
                            showDetail = true
                            detailDocument = document
                        }
                    }
                } label: {
                    Label {
                        Text("Sauvegarder")
                            .fixedSize()
                    } icon: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(userDontAddClient)
                .padding(.bottom)
                
                Button {
                    activeSheet = .apercusDocument
                } label: {
                    Label("Aperçus", systemImage: "eyeglasses")
                }
                .buttonStyle(.bordered)
                
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .navigationDestination(isPresented: $showDetail) {
            if detailDocument != nil {
                DocumentDetailView(document: detailDocument!)
            }
            
        }
    }
}

#Preview {
    //    TypeActeRowView(text: "AAA", price: "50", ttl: .constant(TTLTypeActe(typeActeReal: TypeActe(name: "aa", price: 50, tva: 0.2, context: DataController.shared.container.viewContext), quantity: 1)))
    
    DocumentFormView()
    
    //    ClientRowView(firstname: "AAA", name: "AAA")
}
