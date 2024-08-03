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

struct CreationSeanceSheet: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State private var activeSheet : ActiveSheet? = nil
    
    @State private var dateDebut = Date()
    @State private var typeActes : [TypeActeWithDuration] = []
    @State private var client : Client? = nil
    @State private var commentaire = ""
    @State private var bgColor = Color.green
    @FocusState private var commentIsFocused: Bool
    @State private var chrono : Date = Calendar.current.date(bySettingHour: 1, minute: 0, second: 0, of: Date())!
    
    var body: some View {
        Form {
            Section {
                DatePicker("Début", selection: $dateDebut)
                    .onAppear {
                        UIDatePicker.appearance().minuteInterval = 5
                    }
            }
            
            Section("Client") {
                if let client {
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
            }
            
            Section {
                if !typeActes.isEmpty {
                    ForEach($typeActes, id: \.self) { typeActe in
                        RowTypeActeInfoView(typeActeWithDuree: typeActe)
                    }
                    .onDelete { indexSet in
                        typeActes.remove(atOffsets: indexSet)
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
        .navigationTitle("Nouvelle réservation")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    save()
                    dismiss()
                } label: {
                    Text("Ajouter")
                }
                .disabled(client == nil && typeActes.isEmpty)
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
                    let timeComponents = Int(typeActe.duration_).extractTimeComponents()
                    
                    let typeActeWithDuration = TypeActeWithDuration(typeActe: typeActe, duration: Calendar.current.date(bySettingHour: timeComponents.hour, minute: timeComponents.minute, second: timeComponents.second, of: Date())!)
                    
                    typeActes.append(typeActeWithDuration)
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
        .onDisappear {
            DataController.rollback()
        }
    }
    
    func save() {
        let seanceObject = Seance(context: moc)
        seanceObject.commentaire = commentaire
        seanceObject.dateDebut = dateDebut
        seanceObject.client_ = client
        seanceObject.typeActe_ = NSSet(array: typeActes)
        do {
            try seanceObject.color_ = NSKeyedArchiver.archivedData(withRootObject: bgColor.uiColor, requiringSecureCoding: false)
        } catch {
            print(error)
        }
        
        seanceObject.duration_ = Int64(typeActes.reduce(0, { partialResult, typeActe in
            typeActe.duration.hour ?? 0 + (typeActe.duration.minute ?? 0)
        }))
        
        DataController.saveContext()
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
            
            // TODO: Bouger ce code ailleurs car il est appeler a chaque fois que l'on defocus le timer picker. Donc ça reset le timer tous le temps
            UIDatePicker.appearance().minuteInterval = 5
            
            let timeComponents = Int(typeActeWithDuree.typeActe.duration_).extractTimeComponents()
            
            typeActeWithDuree.duration = Calendar.current.date(bySettingHour: timeComponents.hour, minute: timeComponents.minute, second: timeComponents.second, of: Date())!
        }
    }
}

#Preview {
    NavigationStack {
        CreationSeanceSheet()
    }
}
