//
//  CreationEvenementSheet.swift
//  Bordero
//
//  Created by Grande Variable on 31/07/2024.
//

import SwiftUI
import CoreData

struct TypeActeWithDuration: Hashable {
    let typeActe : TypeActe
    var duration : Date
}

struct FormSeanceSheet: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State var seance : Seance? = nil
    
    @State var dateDebut = Date()
    @State var tabTypeActeWithDuration : [TypeActeWithDuration] = []
    @State var client : Client? = nil
    @State var commentaire = ""
    @State var bgColor = Color.green
    
    @FocusState private var commentIsFocused: Bool
    @State private var activeSheet : ActiveSheet? = nil
    
    var body: some View {
        Form {
            Section {
                DatePicker("Début", selection: $dateDebut)
                    .onAppear {
                        UIDatePicker.appearance().minuteInterval = 5
                    }
            }
            
            Section("Client") {
                switch client {
                case nil :
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
                default :
                    HStack {
                        ClientRowView(client: .constant(client))
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
                }
            }
            
            Section {
                if !tabTypeActeWithDuration.isEmpty {
                    ForEach($tabTypeActeWithDuration, id: \.self) { typeActe in
                        RowTypeActeInfoView(typeActeWithDuree: typeActe)
                    }
                    .onDelete { indexSet in
                        tabTypeActeWithDuration.remove(atOffsets: indexSet)
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
            
            Section {
                TextField("Commentaire", text: $commentaire, axis: .vertical)
                    .focused($commentIsFocused)
                    .lineLimit(3, reservesSpace: true)
                
                ColorPicker("Couleur", selection: $bgColor, supportsOpacity: false)
            }
            
        }
        .navigationTitle(seance == nil ? "Nouvelle évènement" : "Modifier évènement")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    save()
                    dismiss()
                } label: {
                    Text("Ajouter")
                }
                .disabled(client == nil || tabTypeActeWithDuration.isEmpty)
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Text("Annuler")
                }
            }
            
            ToolbarItem(placement: .keyboard) {
                Button {
                    commentIsFocused = false
                } label: {
                    Text("OK")
                }
            }
        }
        .sheet(item: $activeSheet) { activeSheet in
            NavigationStack {
                switch activeSheet {
                case .selectClient:
                    ListClients(callbackClientClick: { client in
                        self.client = client
                    })
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                dismiss()
                            } label: {
                                Text("Retour")
                            }
                        }
                    }
                case .selectTypeActe:
                    ListTypeActe { typeActe in
                        tabTypeActeWithDuration.append(typeActe.getWithDuration())
                    }
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                dismiss()
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
        .onDisappear {
            DataController.rollback()
        }
    }
    
    func save() {
        let seanceObject : Seance = if seance != nil {
            seance!
        } else {
            Seance(context: moc)
        }
        seanceObject.commentaire = commentaire
        seanceObject.startDate = dateDebut
        seanceObject.client_ = client
        
        seanceObject.typeActes = tabTypeActeWithDuration.map { $0.typeActe }
        seanceObject.color = bgColor
        
        // Add
        seanceObject.duration_ = Int64(tabTypeActeWithDuration.reduce(0, { partialResult, typeActe in
            convertHoursToSeconds(hours: typeActe.duration.hour ?? 0) + convertMinutesToSeconds(minutes: typeActe.duration.minute ?? 0)
        }))
        
        DataController.saveContext()
    }
    
    func convertHoursToSeconds(hours: Int) -> Int {
        return hours * 3600
    }
    
    func convertMinutesToSeconds(minutes: Int) -> Int {
        return minutes * 60
    }

}

private struct RowTypeActeInfoView: View {
    @Binding var typeActeWithDuree: TypeActeWithDuration
    
    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(typeActeWithDuree.typeActe.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                DatePicker("Durée", selection: $typeActeWithDuree.duration, displayedComponents: .hourAndMinute)
                    .foregroundStyle(.secondary)
                    
                    .pickerStyle(.wheel)
                    .tint(.primary)
            }
        } icon: {
            Image(systemName: "cross.case.circle.fill")
                .imageScale(.large)
                .foregroundStyle(.white, .purple)
        }
        .onAppear {
            UIDatePicker.appearance().minuteInterval = 5
        }
    }
}

#Preview {
    NavigationStack {
        FormSeanceSheet()
    }
}
