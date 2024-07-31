//
//  CreationEvenementSheet.swift
//  Bordero
//
//  Created by Grande Variable on 31/07/2024.
//

import SwiftUI
import CoreData

//enum Recurrence: String, CaseIterable, Identifiable {
//    case never = "Jamais"
//    case daily = "Tous les jours"
//    case weekly = "Toutes les semaine"
//    case biweekly = "Toutes les 2 semaines"
//    case monthly = "Tous les mois"
////    case yearly = "Tous les ans"
//    
//    var id: String { self.rawValue }
//    
//    // Vous pouvez ajouter une méthode pour obtenir l'intervalle de temps en secondes
//    var timeInterval: TimeInterval? {
//        switch self {
//        case .never:
//            return nil
//        case .daily:
//            return 24 * 60 * 60 // 1 jour
//        case .weekly:
//            return 7 * 24 * 60 * 60 // 1 semaine
//        case .biweekly:
//            return 14 * 24 * 60 * 60 // 2 semaines
//        case .monthly:
//            return 30 * 24 * 60 * 60 // 1 mois approximatif
////        case .yearly:
////            return 365 * 24 * 60 * 60 // 1 an
//        }
//    }
//    
//    // Vous pouvez également ajouter une méthode pour obtenir la prochaine date de récurrence à partir d'une date donnée
//    func nextOccurrence(from date: Date) -> Date? {
//        guard let interval = timeInterval else { return nil }
//        return Calendar.current.date(byAdding: .second, value: Int(interval), to: date)
//    }
//}

struct CreationSeanceSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var seanceObject : Seance
    
    @State private var activeSheet : ActiveSheet? = nil
    @State private var typeActes : [TypeActe] = []
    @State private var client : Client? = nil
    @State private var bgColor = Color.green
    @FocusState private var commentIsFocused: Bool
//    @State private var recurrence : Recurrence = .never
    
//    @State private var intervalRecurrence : Int = 1
    
    init(moc: NSManagedObjectContext) {
        seanceObject = Seance(context: moc)
    }
    
    var body: some View {
        Form {
            Section {
                DatePicker("Début", selection: $seanceObject.dateDebut)
                    .onAppear {
                        UIDatePicker.appearance().minuteInterval = 5
                    }
            }
            
//            Section {
//                Picker("Récurrence", selection: $recurrence) {
//                    ForEach(Recurrence.allCases) { recurrence in
//                        Text(recurrence.rawValue).tag(recurrence)
//                    }
//                }
//                
//                if recurrence != .never {
//                    let finSentence = switch recurrence {
//                    case .never:
//                        ""
//                    case .daily:
//                        "jour(s)"
//                    case .weekly:
//                        "semaine(2)"
//                    case .biweekly:
//                        "2 semaines"
//                    case .monthly:
//                        "mois"
//                    }
                    
//                    LabeledContent("Fréquence") {
//                        
//                        Stepper("\(intervalRecurrence) \(finSentence)", value: $intervalRecurrence, step: 1)
//                    }
                    
//                }
//            }
            
            Section("Client") {
                if let client {
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
                TextField("Commentaire", text: $seanceObject.commentaire, axis: .vertical)
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
                    typeActes.append(typeActe)
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
        seanceObject.client_ = client
        seanceObject.typeActe_ = NSSet(array: typeActes)
        do {
            try seanceObject.color_ = NSKeyedArchiver.archivedData(withRootObject: bgColor.uiColor, requiringSecureCoding: false)
        } catch {
            print(error)
        }
        
        seanceObject.duration_ = typeActes.reduce(0) { (result, typeActe) -> Double in
            let interval = typeActe.duree.timeIntervalSince(seanceObject.dateDebut)
            return result + interval
        } // affecte l'addition des durées des types d'actes pour obtenir le temps global
        
        DataController.saveContext()
    }
}

private struct RowTypeActeInfoView: View {
    @Binding var typeActeWithDuree: TypeActe
    
    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(typeActeWithDuree.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                DatePicker("Durée", selection: $typeActeWithDuree.duree, displayedComponents: .hourAndMinute)
                    .foregroundStyle(.secondary)
                    .onAppear {
                        UIDatePicker.appearance().minuteInterval = 5
                    }
            }
            .tint(.primary)
        } icon: {
            Image(systemName: "cross.case.circle.fill")
                .imageScale(.large)
                .foregroundStyle(.white, .purple)
        }
    }
}

#Preview {
    NavigationStack {
        CreationSeanceSheet(moc: DataController.shared.container.viewContext)
    }
}
