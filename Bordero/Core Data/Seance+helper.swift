//
//  Seance+helper.swift
//  Bordero
//
//  Created by Grande Variable on 31/07/2024.
//

import Foundation
import CoreData
import SwiftUI
import SimpleCalendar

extension Seance {
    
    var uuid : UUID {
#if DEBUG
        id!
#else
        id ?? UUID()
#endif
    }
    
    var startDate : Date {
        get {
            return startDate_ ?? Date()
        }
        set {
            startDate_ = newValue
        }
    }
    
    var commentaire : String {
        get {
            return comment_ ?? ""
        }
        set {
            comment_ = newValue
        }
    }
    
    var color : Color {
        get {
            guard let color_ else { return .blue }
            return Color(data: color_) ?? .blue
        }
        set {
            color_ = newValue.toData()
        }
    }
    
    var typeActes : [TypeActe] {
        get {
            return typeActe_?.allObjects as? [TypeActe] ?? []
        }
        set {
            typeActe_ = NSSet(array: newValue)
        }
    }
    
    var titre : String {
        get {
            if let client_ {
                "Séance \(client_.fullname)"
            } else {
                "Inconnu"
            }
        }
    }
    
    var durationConvertie : String {
        get {
            let secondes = Int(duration_)
            let heures = secondes / 3600
            let minutes = (secondes % 3600) / 60
            
            if heures > 0 {
                return heures == 1 ? "1 heure" : "\(heures) heures"
            } else if minutes > 0 {
                return minutes == 1 ? "1 minute" : "\(minutes) minutes"
            } else {
                return "moins d'une minute"
            }
        }
    }
    
    func convertToCalendarActivity() -> CalendarActivity {
        let activityType = ActivityType(name: "Réservation", color: color)
        
        return CalendarActivity(
            id: uuid.uuidString,
            title: titre,
            description: commentaire,
            mentors: [],
            type: activityType,
            duration: Double(duration_)
        )
    }
    
    public override func awakeFromInsert() {
        self.id = UUID()
    }
    
    static var example : Seance {
        let context = DataController.shared.container.viewContext
        let seance = Seance(context: context)
        seance.startDate = Date().atHour(11, minute: 28) ?? Date()
        seance.commentaire = "AAAAAAAAAA"
        seance.client_ = Client.example
        seance.typeActes = []
        seance.duration_ = Int64(3600*3)
        return seance
    }
}


extension Color {
    init?(data: Data) {
        guard let components = try? JSONDecoder().decode([CGFloat].self, from: data), components.count >= 3 else {
            return nil
        }
        self = Color(
            .sRGB,
            red: components[0],
            green: components[1],
            blue: components[2],
            opacity: components.count > 3 ? components[3] : 1.0
        )
    }
    
    func toData() -> Data? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        let colorData = try? JSONEncoder().encode(components)
        return colorData
    }
}
