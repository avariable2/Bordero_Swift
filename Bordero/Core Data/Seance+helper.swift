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
    
    public override func awakeFromInsert() {
        self.id = UUID()
    }
    
    func convertToCalendarActivity() -> CalendarActivity {
        return CalendarActivity(
            id: uuid.uuidString,
            title: titre,
            description: commentaire,
            mentors: [],
            type: CalendarViewModel.exerciseType,
            duration: Double(duration_)
        )
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
