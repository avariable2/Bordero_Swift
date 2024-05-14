//
//  ClientDataUtils.swift
//  Bordero
//
//  Created by Grande Variable on 11/05/2024.
//

import SwiftUI

struct ClientDataUtils {
    
    static func getSixMonthPeriodRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        
        let year = calendar.component(.year, from: now)
        var startComponents = DateComponents(year: year)
        var endComponents = DateComponents(year: year, month: 7, day: 1)
        
        if month >= 1 && month <= 6 {
            // Dans les 6 premiers mois, donc de janvier à juin
            startComponents.month = 1
            endComponents.month = 7
            endComponents.day = 1
        } else {
            // Dans les 6 derniers mois, donc de juillet à décembre
            startComponents.month = 7
            endComponents.year = year + 1
            endComponents.month = 1
            endComponents.day = 1
        }
        
        let startDate = calendar.date(from: startComponents)!
        let endDate = calendar.date(from: endComponents)!
        
        return (startDate, endDate)
    }
    
    static func getTextTemporalite(temporalite : TempoChart) -> String {
        switch temporalite {
        case .semaine:
            let calendar = Calendar.current
            let now = Date()
            
            // Calculate the start of the week
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            
            // Add 6 days to get the end of the week
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            return "\(weekStart.formatted(.dateTime.day()))-\(weekEnd.formatted(.dateTime.day())) \(now.formatted(.dateTime.month().year()))"
        case .mois:
            return Date().formatted(.dateTime.month().year())
        case .sixMois:
            let range = ClientDataUtils.getSixMonthPeriodRange()
            return "\(range.start.formatted(.dateTime.day().month()))-\(range.end.formatted(.dateTime.day().month().year()))"
        case .annee:
            return Date().formatted(.dateTime.year())
        }
    }
}
