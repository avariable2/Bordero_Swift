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
    var events : [CalendarSeanceEvent] = []
    
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
    
    func getEvents() -> [CalendarSeanceEvent] {
        var tabEvents : [CalendarSeanceEvent] = []
        
        for seance in seances {
            let calendarActivity = seance.convertToCalendarActivity()
            
            tabEvents.append(CalendarSeanceEvent(
                id: calendarActivity.id,
                startDate: seance.startDate,
                activity: calendarActivity, 
                seance: seance
            ))
        }
        return tabEvents
    }
}

public struct CalendarSeanceEvent: CalendarEventRepresentable, Identifiable, Equatable {
    
    public static func == (lhs: CalendarSeanceEvent, rhs: CalendarSeanceEvent) -> Bool {
        lhs.id == rhs.id
    }
    public let id: String
    public let startDate: Date
    public let calendarActivity: any CalendarActivityRepresentable

    public var coordinates: CGRect?
    public var column: Int = 0
    public var columnCount: Int = 0
    
    public var seance : Seance

    /// The CalendarEvent initialiser
    /// - Parameters:
    ///   - id: The event identifier
    ///   - startDate: The start date and time of the event
    ///   - calendarActivity: The ``CalendarActivity`` this event is representing
    public init(
        id: String,
        startDate: Date,
        activity: CalendarActivityRepresentable,
        seance: Seance
    ) {
        self.id = id
        self.startDate = startDate
        self.calendarActivity = activity
        self.seance = seance

        self.coordinates = nil
        self.column = 0
        self.columnCount = 0
    }
}
