//
//  CalendarKitView.swift
//  Bordero
//
//  Created by Grande Variable on 30/07/2024.
//

import UIKit
import CalendarKit
import EventKit
import SwiftUI
import EventKitUI

class CalendarViewController : DayViewController {
    private let eventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calendrier"
        requestAccessToCalendar()
        subscribeToNotifications()
    }
    
    func requestAccessToCalendar() {
        eventStore.requestFullAccessToEvents { requestAccess, error in
            
        }
    }
    
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)), name: .EKEventStoreChanged, object: nil)
    }
    
    @objc func storeChanged(_ notification: Notification) {
        reloadData()
    }
    
    override func eventsForDate(_ date: Date) -> [any EventDescriptor] {
        let startDate = date
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        
        let endDate = calendar.date(byAdding: oneDayComponents, to: startDate)!
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        
        let eventKitEvents = eventStore.events(matching: predicate)
        
        let calendarKitEvents = eventKitEvents.map(EKWrapper.init)
        
        return calendarKitEvents
    }
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let ckEvent = eventView.descriptor as? EKWrapper else {return}
        
        let ekEvent = ckEvent.ekEvent
        presentDetailView(ekEvent: ekEvent)
    }
    
    private func presentDetailView(ekEvent : EKEvent) {
        let eventViewController = EKEventViewController()
        eventViewController.event = ekEvent
        eventViewController.allowsCalendarPreview = true
        eventViewController.allowsEditing = true
        
        navigationController?.pushViewController(eventViewController, animated: true)
    }
    
    func createEvent() {
        let event = EKEvent(eventStore: eventStore)
        event.title = "RDV"
        var startDateComponents = DateComponents()
        startDateComponents.day = 1
        
        let startDate = Calendar.current.date(from: startDateComponents)
        event.startDate = startDate
        event.endDate = Calendar.current.date(byAdding: .hour, value: 2, to: startDate!)
        event.timeZone = TimeZone(identifier: "America/Los_Angeles")
        event.location = "aaa"
        event.notes = ""
        
        // Create viewController
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.event = event
        eventEditViewController.eventStore = eventStore
        
        present(eventEditViewController, animated: true)
    }
}

struct CalendarController: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewController, context: Context){
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let dayViewController = CalendarViewController()
        return dayViewController
    }
}
