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

struct ModifierDocumentView: View, Saveable, Versionnable {
    static func getVersion() -> Int32 {
        return 1
    }
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var moc
    
    var viewModel : PDFViewModel
    
    @State private var activeSheet: ActiveSheet?
    
    @State private var client : Client? = nil
    @State private var listTypeActes = [TTLTypeActe]()
    
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
                    if !listTypeActes.isEmpty {
                        ForEach(listTypeActes.indices, id: \.self) { index in
                            TypeActeRowView(
                                text: listTypeActes[index].typeActeReal.name,
                                price: listTypeActes[index].typeActeReal.total,
                                ttl: $listTypeActes[index],
                                onDelete: {
                                    listTypeActes.remove(at: index)
                                }
                            )
                        }
                        .onDelete(perform: { indexSet in
                            listTypeActes.remove(atOffsets: indexSet)
                        })
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
                    .disabled(listTypeActes.count >= 4)
                } header : {
                    Text("Préstation(s)")
                } footer : {
                    Text("Pour supprimer un élément de la liste, déplacé le sur la gauche.")
                }
                .onChange(of: listTypeActes) { oldValue, newValue in
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
                        model: viewModel.documentData,
                        callback: {
                            self.save()
                        }
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
                    ListTypeActe(callbackClick: { type in
                        listTypeActes.append(TTLTypeActe(typeActeReal: type, quantity: 1))
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
                default:
                    EmptyView() // IMPOSSIBLE
                }
            }
            
        }
    }
    
    func save() {
        let document = viewModel.getDocument()
        
        print(document)
        
//        do {
//            try moc.save()
//            
//        } catch _ {
//            
//        }
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
    let text : String
    let price : Double
    @Binding var ttl : TTLTypeActe
    @State private var showSheet = false
    
    let onDelete : () -> Void
    
    var body: some View {
        Button {
            showSheet.toggle()
        } label: {
            Label {
                VStack(alignment: .leading, spacing: 5) {
                    
                    HStack {
                        Text(text)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                onDelete()
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .symbolRenderingMode(.monochrome)
                                .foregroundStyle(.red)
                        }
                    }
                    
                    LabeledContent("Quantité", value: ttl.quantity, format: .number)
                        .foregroundStyle(.secondary)
                    
                    LabeledContent("Prix", value: price, format: .currency(code: "EUR"))
                        .foregroundStyle(.secondary)
                    
                    if !Calendar.current.isDateInToday(ttl.date) {
                        LabeledContent("Date", value: ttl.date.formatted(.dateTime.day().month().year()))
                            .foregroundStyle(.secondary)
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
                        value: $ttl.quantity,
                        in: 0...100
                    ) {
                        Text(ttl.quantity, format: .number)
                    }
                    
                }
                
                DatePicker("Date de l'acte", selection: $ttl.date, displayedComponents: .date)
                
            }
            .padding()
            .navigationTitle("Option de \(text)")
            .presentationDetents([.fraction(0.2), .medium])
        }
    }
}

struct FormButtonsPrimaryActionView: View {
    @Binding var activeSheet : ActiveSheet?
    var model : PDFModel
    
    var callback : () -> Void
    
    private var userDontAddClient : Bool {
        model.client == nil
    }
    
    var body: some View {
        ViewThatFits {
            HStack {
                NavigationLink {
                    DocumentDetailView(documentData: model)
                } label: {
                    Label {
                        Text("Sauvegarder")
                            .fixedSize()
                    } icon: {
                        Image(systemName: "square.and.arrow.down")
                    }
                    .onTapGesture(perform: {
                        callback()
                    })
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                    )
                }
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
                NavigationLink {
                    DocumentDetailView(documentData: model)
                } label: {
                    Label {
                        Text("Sauvegarder")
                            .fixedSize()
                    } icon: {
                        Image(systemName: "square.and.arrow.down")
                    }
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                    )
                }
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
    }
}

#Preview {
    //    TypeActeRowView(text: "AAA", price: "50", ttl: .constant(TTLTypeActe(typeActeReal: TypeActe(name: "aa", price: 50, tva: 0.2, context: DataController.shared.container.viewContext), quantity: 1)))
    
    DocumentFormView()
    
    //    ClientRowView(firstname: "AAA", name: "AAA")
}
