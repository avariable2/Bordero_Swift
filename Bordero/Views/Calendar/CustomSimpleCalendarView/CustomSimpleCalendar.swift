//
//  CustomSimpleCalendar.swift
//  Bordero
//
//  Created by Grande Variable on 30/07/2024.
//

import SwiftUI
import SimpleCalendar

/// A Simple Calendar view containing the events and activities send in
/// This specific class is rewrite for match my specific need.
public struct CustomSimpleCalendarView: View {
    /// The events the calendar should show
    @Binding var events: [CalendarEvent]
    @Binding var selectedDate: Date

    @State private var visibleEvents: [any CalendarEventRepresentable]
    @State private var hourHeight: Double
    @State private var hourSpacing: Double

    private let startHourOfDay: Int
    private let endHourOfDay: Int
    private let selectionAction: SelectionAction
    private let dateSelectionStyle: DateSelectionStyle

    /// Simple Calendar should be initialised with events. The remaining have a default value.
    /// - Parameters:
    ///   - events: The list of events that the calendar should show. Should be a list of ``CalendarEventRepresentable``, such as ``CalendarEvent``.
    ///   - selectedDate: The date the calendar show show, defaults to todays date
    ///   - selectionAction: The action the calendar should perform when a user selects an event. Defaults to `.sheet`
    ///   - dateSelectionStyle: The type of date selection in the toolbar, default is `.datePicker`
    ///   - hourHeight: The height for each hour label.  Defaults to `25.0`
    ///   - hourSpacing: The vstack spacing between each hour label. Defaults to `24.0`
    ///   - startHourOfDay: The first hour of the day to show. Defaults to `6` as 6 in the morning / 6 am
    ///   - endHourOfDay: The last hour of the day to show. Defaults to `24` as 00 in the morning / 12pm
    public init(
        events: Binding<[CalendarEvent]>,
        selectedDate: Binding<Date>,
        selectionAction: SelectionAction = .sheet,
        dateSelectionStyle: DateSelectionStyle = .datePicker,
        hourHeight: Double = 25.0,
        hourSpacing: Double = 24.0,
        startHourOfDay: Int = 6,
        endHourOfDay : Int = 24
    ) {
        _events = events
        _selectedDate = selectedDate
        _visibleEvents = State(initialValue: events.wrappedValue)
        _hourHeight = State(initialValue: hourHeight)
        _hourSpacing = State(initialValue: hourSpacing)

        self.startHourOfDay = startHourOfDay
        self.selectionAction = selectionAction
        self.dateSelectionStyle = dateSelectionStyle
        self.endHourOfDay = endHourOfDay
    }

    private var hours: [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        var hours: [String] = []

        for hour in startHourOfDay...endHourOfDay {
            if let date = Date().atHour(hour) {
                hours.append(dateFormatter.string(from: date))
            }
        }

        return hours
    }
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMdd")
        return dateFormatter
    }()

    /// The date selection style added to the navigation bar
    public enum DateSelectionStyle {
        /// The system default date picker
        case datePicker

        /// A range of dates provided by the app
        case selectedDates([Date])
    }

    public var body: some View {
        ScrollView {
            ZStack {
                CalendarPageView(
                    hours: hours,
                    hourSpacing: $hourSpacing,
                    hourHeight: $hourHeight
                )
                .zIndex(1)

                let calendar = Calendar.current
                if calendar.isDateInToday(selectedDate) {
                    CalendarTimelineView(
                        startHourOfDay: startHourOfDay,
                        hourSpacing: $hourSpacing,
                        hourHeight: $hourHeight
                    )
                    .zIndex(3)
                }

                CalendarContentView(
                    events: $visibleEvents,
                    selectionAction: selectionAction
                )
                .zIndex(2)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ZStack {
                        switch dateSelectionStyle {
                        case .datePicker:
                            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                                .labelsHidden()
                        case .selectedDates(let dates):
                            Picker(selection: $selectedDate) {
                                ForEach(dates, id:\.self) { date in
                                    Text(date, style: .date)
                                }
                            } label: {
                                Text("")
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: events) { oldValue, newValue in
            updateContent()
        }
        .onChange(of: selectedDate) { _, _ in
            updateContent()
        }
        .onAppear {
            updateContent()
        }
    }

    private func updateContent() {
        let calendar = Calendar.current
        let selectedEvents = events.filter {
            calendar.isDate($0.startDate, inSameDayAs: selectedDate)
            || calendar.isDate($0.startDate.addingTimeInterval($0.calendarActivity.duration), inSameDayAs: selectedDate)
        }

        calculateCoordinates(forEvents: selectedEvents)
    }

    private func calculateCoordinates(forEvents events: [any CalendarEventRepresentable]) {
        var eventList: [any CalendarEventRepresentable] = []

        var pos: [EventPositions] = []

        let actualHourHeight = hourHeight + hourSpacing
        let heightPerSecond = (actualHourHeight / 60) / 60

        // Go over each event and check if there is another event ongoing at the same time
        events.forEach { event in
            let activity = event.calendarActivity
            var event = event

            let secondsSinceStartOfDay = abs(selectedDate.atHour(startHourOfDay)?.timeIntervalSince(event.startDate) ?? 0)

            let frame = CGRect(x: 0, y: secondsSinceStartOfDay * heightPerSecond, width: 60, height: activity.duration * heightPerSecond)
            event.coordinates = frame

            let positionedEvents = pos.filter {
                ($0.position.minY >= frame.origin.y && $0.position.minY < frame.maxY) ||
                ($0.position.maxY > frame.origin.y && $0.position.maxY <= frame.maxY)
            }

            event.column = positionedEvents.count
            event.columnCount = positionedEvents.count

            let returnList = eventList.map {
                var event = $0
                if positionedEvents.contains(where: { $0.id == event.id }) {
                    event.columnCount += 1
                }
                return event
            }
            eventList = returnList
            eventList.append(event)

            pos.append(EventPositions(id: event.id, sharePositionWith: positionedEvents.map { $0.id }, position: frame))
        }

        self.visibleEvents = eventList
    }

    private func calculateOffset(event: CalendarEvent) -> Double {
        guard let startHour = event.startDate.hour, let dateHour = Date().atHour(startHour) else { return 0 }

        let actualHourHeight = hourHeight + hourSpacing
        let heightPerSecond = (actualHourHeight / 60) / 60
        let secondsSinceStartOfDay = abs(Date().atHour(0)?.timeIntervalSince(dateHour) ?? 0)
        return secondsSinceStartOfDay * heightPerSecond
    }
}

private struct EventPositions {
    var id: String
    var sharePositionWith: [String] = []
    var position: CGRect
}
