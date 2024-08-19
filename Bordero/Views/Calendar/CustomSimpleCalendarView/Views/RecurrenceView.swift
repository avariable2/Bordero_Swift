//
//  RecurrenceView.swift
//  Bordero
//
//  Created by Grande Variable on 02/08/2024.
//

import SwiftUI

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

struct RecurrenceView: View {
    //    @State private var recurrence : Recurrence = .never
    //    @State private var intervalRecurrence : Int = 1
    
    var body: some View {
//        Section {
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
            
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    RecurrenceView()
}
