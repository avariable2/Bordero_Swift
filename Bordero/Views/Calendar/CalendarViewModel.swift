//
//  CalendarViewModel.swift
//  Bordero
//
//  Created by Thomas Vary on 05/08/2024.
//

import Foundation
import SimpleCalendar
import SwiftUI
import CoreData

@Observable
class CalendarViewModel {
    static let exerciseType = ActivityType(name: "Réservation", color: Color.blue)
    
    var seances : [Seance] = []
    var events : [CalendarEvent] = []
    
    func fetchCalendarSeances(_ viewContext : NSManagedObjectContext, targetDate : Date = Date()) {
        let request: NSFetchRequest<Seance> = Seance.fetchRequest()
        
        let startDate = Calendar.current.startOfDay(for: targetDate)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        
        let predicate = NSPredicate(
            format: "startDate_ >= %@ AND startDate_ < %@", startDate as NSDate, endDate as NSDate)
        request.predicate = predicate
        
        do {
            seances = try viewContext.fetch(request)
        } catch {
            print("Erreur lors de la récupération des seances : \(error.localizedDescription)")
        }
        
        events = getEvents()
    }
    
    func getEvents() -> [CalendarEvent] {
        var tabEvents : [CalendarEvent] = []
        
        for seance in seances {
            let calendarActivity = seance.convertToCalendarActivity()
            
            tabEvents.append(CalendarEvent(
                id: calendarActivity.id,
                startDate: seance.startDate,
                activity: calendarActivity
            ))
        }
        return tabEvents
    }
}
