//
//  MainCalendarView.swift
//  Bordero
//
//  Created by Grande Variable on 29/07/2024.
//

import SwiftUI
import SimpleCalendar

struct MainCalendarView: View {
    @Environment(\.managedObjectContext) var moc
    
//    @FetchRequest(
//        sortDescriptors: [],
//        predicate: NSPredicate(
//            format: "startDate_ >= %@ AND startDate_ < %@", Calendar.current.startOfDay(for: Date()) as NSDate, Calendar.current.date(byAdding: .day, value: 1, to: Date())! as NSDate)
//    ) var seances : FetchedResults<Seance>
    
    @State private var viewModel = CalendarViewModel()
    @State private var selectedDate = Date()
    @State private var activeSheet : ActiveSheet? = nil
    
    var body: some View {
        VStack {
            CustomSimpleCalendarView(
                events: $viewModel.events,
                selectedDate: $selectedDate,
                selectionAction: .destination({ calendarSeanceEvent in
                    CalendarSeanceView(seance: (calendarSeanceEvent as! CalendarSeanceEvent).seance)
                }),
                hourSpacing: 30,
                startHourOfDay: 8
            )
        }
        .task {
            viewModel.fetchCalendarSeances(moc)
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            viewModel.fetchCalendarSeances(moc, targetDate: newValue)
        }
        .navigationTitle(selectedDate.formatted(.dateTime.weekday(.wide)).capitalized)
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
        .sheet(item: $activeSheet) {
            viewModel.fetchCalendarSeances(moc, targetDate: selectedDate)
        } content: { activeSheet in
            NavigationStack {
                switch activeSheet {
                case .createSeance:
                    FormSeanceSheet()
                default:
                    EmptyView() // Impossible
                }
            }
        }
        .trackEventOnAppear(event: .calendarListBrowsed, category: .calendarManagement)
    }
}

#Preview {
    NavigationStack {
//        MainCalendarView()
    }
}

private extension Date {
    func bySettingHour(_ hour: Int, minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self)!
    }
}
