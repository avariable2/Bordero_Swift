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
        sortDescriptors: [],
        predicate: NSPredicate(
            format: "startDate_ >= %@ AND startDate_ < %@", Calendar.current.startOfDay(for: Date()) as NSDate, Calendar.current.date(byAdding: .day, value: 1, to: Date())! as NSDate)
    ) var seances : FetchedResults<Seance>
    
    @State private var viewModel = CalendarViewModel()
    @State private var selectedDate = Date()
    @State private var activeSheet : ActiveSheet? = nil
    
    var body: some View {
        
        VStack {
            
            Text("Nombre d'entity : \(seances.count)")
            List {
                ForEach(seances, id: \.self) { s in
                    Text("\(s.startDate)")
                }.onDelete(perform: delete)
            }
            .frame(height: 200)
            
            CustomSimpleCalendarView(
                events: $viewModel.events,
                selectedDate: $selectedDate,
                hourSpacing: 30,
                startHourOfDay: 8
            )
        }
        .task {
            viewModel.fetchPayments(moc)
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
                    CreationSeanceSheet()
                default:
                    EmptyView() // Impossible
                }
            }
            
        }
        .trackEventOnAppear(event: .calendarListBrowsed, category: .calendarManagement)
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let seance = seances[index]
            moc.delete(seance)
        }
        DataController.saveContext()
    }
}

@Observable
class CalendarViewModel {
    static let exerciseType = ActivityType(name: "Réservation", color: Color.blue)
    
    var seances : [Seance] = []
    var events : [CalendarEvent] = []
    
    func fetchPayments(_ viewContext : NSManagedObjectContext, targetDate : Date = Date()) {
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
