//
//  MainCalendarView.swift
//  Bordero
//
//  Created by Grande Variable on 29/07/2024.
//

import SwiftUI
import SimpleCalendar
import CoreData

struct MainCalendarView: View {
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(
        sortDescriptors: []
    ) var seances : FetchedResults<Seance>
    
    private let dataModel = DataModel()
    
    @State private var events: [any CalendarEventRepresentable] = []
    @State private var selectedDate = Date()
    
    @State private var activeSheet : ActiveSheet? = nil
    
    @State private var viewModel = CalendarViewModel()
    
    var body: some View {
        
        VStack {
            
            Text("Nombre d'entity : \(seances.count)")
            List(seances) { s in
                Text("\(s.dateDebut)")
            }.frame(height: 200)
            
            CustomSimpleCalendarView(
                events: $viewModel.events,
                selectedDate: $selectedDate,
                hourSpacing: 50,
                startHourOfDay: 8
            )
            
            //            List(viewModel.seances) { s in
            //                Text(s.dateDebut, format: .dateTime)
            //            }
        }
        .onAppear() {
            viewModel.fetchPayments(moc, targetDate: Date())
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            viewModel.fetchPayments(moc, targetDate: newValue)
        }
        .navigationTitle("\(selectedDate.formatted(.dateTime.weekday(.wide)).capitalized)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    activeSheet = .createSeance
                } label: {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundStyle(.green, .blue)
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                DayPickerView(selectedDay: $selectedDate)
            }
        }
        .sheet(item: $activeSheet) { activeSheet in
            NavigationStack {
                switch activeSheet {
                case .createSeance:
                    CreationSeanceSheet(moc: moc)
                default:
                    EmptyView() // Impossible
                }
            }
            
        }
    }
}

@Observable
class CalendarViewModel {
    let exerciseType = ActivityType(name: "Réservation", color: Color.blue)
    var seances : [Seance] = []
    
    var selectedDate : Date = Date()
    
    var events : [any CalendarEventRepresentable] = []
    
    func fetchPayments(_ viewContext : NSManagedObjectContext, targetDate : Date) {
        let request: NSFetchRequest<Seance> = Seance.fetchRequest()
        
        selectedDate = targetDate
        
        let startDate = Calendar.current.startOfDay(for: targetDate)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        
        let predicate = NSPredicate(format: "startDate_ >= %@ AND startDate_ < %@", startDate as NSDate, endDate as NSDate)
        request.predicate = predicate
        
        do {
            seances = try viewContext.fetch(request)
        } catch {
            print("Erreur lors de la récupération des seances : \(error.localizedDescription)")
        }
        
        events = getEvents()
    }
    
    func convertToCalendarActivity() -> [CalendarActivity] {
        return seances.map { seance in
            CalendarActivity(
                id: seance.hashValue.description,
                title: seance.titre,
                description: seance.commentaire,
                mentors: [""],
                type: exerciseType,
                duration: seance.duration_
            )
        }
    }
    
    func getEvents() -> [CalendarEvent] {
        let listCalendarActivity = convertToCalendarActivity()
        if let cActivity = listCalendarActivity.first {
            return [
                CalendarEvent(id: "eeeeee", startDate: selectedDate, activity: cActivity)
            ]
        }
        return []
    }
    
    private func getMinutes(from date: Date) -> Int {
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        return minutes
    }
    
    private func getHour(from date: Date) -> Int {
        let hour = date.hour
        return hour ?? 0
    }
}


class DataModel {
    private let activities: [CalendarActivity] = {
        // ActivityTypes
        let exerciseType = ActivityType(name: "Exercise", color: Color.red)
        let mealType = ActivityType(name: "Meal", color: Color.green)
        let studyType = ActivityType(name: "Study", color: Color.blue)
        let entertainmentType = ActivityType(name: "Entertainment", color: Color.purple)
        let relaxationType = ActivityType(name: "Relaxation", color: Color.yellow)
        
        // Activities based on the given ActivityType instances
        let wakeup = CalendarActivity(
            id: UUID().uuidString,
            title: "Wakeup",
            description: "Time to start a new day.",
            mentors: [""],
            type: relaxationType,
            duration: 600
        )
        
        let jogging = CalendarActivity(
            id: UUID().uuidString,
            title: "Morning Jog",
            description: "A brisk morning jog around the park to get the blood pumping.",
            mentors: ["John Doe"],
            type: exerciseType,
            duration: 1.0 * 3600 // 1 hour
        )
        
        let breakfast = CalendarActivity(
            id: UUID().uuidString,
            title: "Breakfast",
            description: "A healthy meal to start the day with energy.",
            mentors: [],
            type: mealType,
            duration: 0.5 * 3600 // 30 minutes
        )
        
        let reading = CalendarActivity(
            id: UUID().uuidString,
            title: "Reading",
            description: "Reading a chapter from a self-help book.",
            mentors: ["Jane Smith"],
            type: studyType,
            duration: 1.5 * 3600 // 1 hour 30 minutes
        )
        
        let movie = CalendarActivity(
            id: UUID().uuidString,
            title: "Watch a Movie",
            description: "Watching a classic movie.",
            mentors: [],
            type: entertainmentType,
            duration: 2.0 * 3600 // 2 hours
        )
        
        let meditation = CalendarActivity(
            id: UUID().uuidString,
            title: "Meditation",
            description: "A calm session of mindfulness and breathing exercises.",
            mentors: ["Guru Dan"],
            type: relaxationType,
            duration: 0.5 * 3600 // 30 minutes
        )
        
        return [
            wakeup,
            jogging,
            breakfast,
            reading,
            movie,
            meditation
        ]
    }()
    
    func getEvents() -> [CalendarEvent] {
        let dateToday = Date()
        let dateTomorrow = Date(timeIntervalSinceNow: 24 * 3600)
        let dateTenDaysFromNow = Date(timeIntervalSinceNow: (24 * 3600) * 10)
        
        let eventsToday = [
            CalendarEvent(id: "wakeup", startDate: dateToday.bySettingHour(8, minute: 10), activity: getActivities(withTitle: "Wakeup")!),
            CalendarEvent(id: "1jog", startDate: dateToday.bySettingHour(8, minute: 30), activity: getActivities(withTitle: "Morning Jog")!),
            CalendarEvent(id: "1breakfast", startDate: dateToday.bySettingHour(9, minute: 30), activity: getActivities(withTitle: "Breakfast")!),
            CalendarEvent(id: "1Meditation", startDate: dateToday.bySettingHour(9, minute: 30), activity: getActivities(withTitle: "Meditation")!),
            CalendarEvent(id: "1reading", startDate: dateToday.bySettingHour(10, minute: 30), activity: getActivities(withTitle: "Reading")!),
            CalendarEvent(id: "1Meditation2", startDate: dateToday.bySettingHour(15, minute: 30), activity: getActivities(withTitle: "Meditation")!),
            CalendarEvent(id: "1reading2", startDate: dateToday.bySettingHour(15, minute: 45), activity: getActivities(withTitle: "Reading")!),
            CalendarEvent(id: "1movie", startDate: dateToday.bySettingHour(21, minute: 0), activity: getActivities(withTitle: "Watch a Movie")!)
        ]
        
        let eventTomorrow = [
            CalendarEvent(id: "wakeup", startDate: dateTomorrow.bySettingHour(8, minute: 10), activity: getActivities(withTitle: "Wakeup")!),
            CalendarEvent(id: "2jog", startDate: dateTomorrow.bySettingHour(8, minute: 30), activity: getActivities(withTitle: "Morning Jog")!),
            CalendarEvent(id: "2breakfast", startDate: dateTomorrow.bySettingHour(9, minute: 30), activity: getActivities(withTitle: "Breakfast")!),
            CalendarEvent(id: "2Meditation", startDate: dateTomorrow.bySettingHour(10, minute: 30), activity: getActivities(withTitle: "Meditation")!),
            CalendarEvent(id: "2Meditation2", startDate: dateTomorrow.bySettingHour(15, minute: 30), activity: getActivities(withTitle: "Meditation")!),
            CalendarEvent(id: "2reading2", startDate: dateTomorrow.bySettingHour(15, minute: 45), activity: getActivities(withTitle: "Reading")!)
        ]
        
        let tenDaysFromNow = [
            CalendarEvent(id: "wakeup", startDate: dateTenDaysFromNow.bySettingHour(6, minute: 10), activity: getActivities(withTitle: "Wakeup")!),
            CalendarEvent(id: "2jog", startDate: dateTenDaysFromNow.bySettingHour(6, minute: 30), activity: getActivities(withTitle: "Morning Jog")!)
        ]
        
        return eventsToday + eventTomorrow + tenDaysFromNow
    }
    
    private func getActivities(withTitle title: String) -> CalendarActivity? {
        activities.first(where: { $0.title == title })
    }
}


#Preview {
    NavigationStack {
        MainCalendarView()
    }
}

private extension Date {
    func bySettingHour(_ hour: Int, minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self)!
    }
}
