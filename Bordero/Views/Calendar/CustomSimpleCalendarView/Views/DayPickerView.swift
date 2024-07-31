//
//  DayPickerView.swift
//  Bordero
//
//  Created by Grande Variable on 31/07/2024.
//

import SwiftUI

struct DayPickerView: View {
    enum DaySelection: String, CaseIterable, Identifiable, Equatable {
        case yesterday
        case today
        case tomorrow
        case dayAfterTomorrow
        
        var id: String { self.rawValue }
        
        var date: Date {
            switch self {
            case .yesterday:
                return Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            case .today:
                return Date()
            case .tomorrow:
                return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            case .dayAfterTomorrow:
                return Calendar.current.date(byAdding: .day, value: 2, to: Date())!
            }
        }
        
    }
    
    @Binding var selectedDay: Date /* = DaySelection.today.date*/
    
    var body: some View {
        Picker("Sélectionnez un jour", selection: $selectedDay) {
            ForEach(DaySelection.allCases) { day in
                Text("\(day.date == Date() ? "⏺️ " : "")\(day.date, format: .dateTime.day()) \(day.date, format: .dateTime.month())")
                    .tag(day.date)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
}
#Preview {
    DayPickerView(selectedDay: .constant(Date()))
}
