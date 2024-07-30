//
//  TestCalendar.swift
//  Bordero
//
//  Created by Grande Variable on 30/07/2024.
//

import SwiftUI

struct Event: Identifiable {
    let id = UUID()
    var startDate: Date
    var endDate: Date
    var title: String
}


struct TestCalendar: View {
    
    let date: Date = dateFrom(9, 5, 2023)
    
    let events: [Event] = [
        Event(startDate: dateFrom(9,5,2023,7,0), endDate: dateFrom(9,5,2023,8,0), title: "Event 1"),
        Event(startDate: dateFrom(9,5,2023,9,0), endDate: dateFrom(9,5,2023,10,0), title: "Event 2"),
        Event(startDate: dateFrom(9,5,2023,11,0), endDate: dateFrom(9,5,2023,12,00), title: "Event 3"),
        Event(startDate: dateFrom(9,5,2023,13,0), endDate: dateFrom(9,5,2023,14,45), title: "Event 4"),
        Event(startDate: dateFrom(9,5,2023,15,0), endDate: dateFrom(9,5,2023,15,45), title: "Event 5"),
    ]
    
    let hourHeight = 90.0
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // Date headline
            HStack {
                Text(date.formatted(.dateTime.day().month()))
                    .bold()
                Text(date.formatted(.dateTime.year()))
            }
            .font(.title)
            
            Text(date.formatted(.dateTime.weekday(.wide)))
            
            ScrollView {
                ZStack(alignment: .topLeading) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(7..<19) { hour in
                            HStack {
                                
                                ViewThatFits {
                                    Text(String(format: "%02i:00", hour))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(alignment: .trailing)
                                    
                                    Text(String(format: "%02i", hour))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(alignment: .trailing)
                                }
                                
                                Color.gray
                                    .frame(height: 1)
                            }
                            .frame(height: hourHeight)
                        }
                    }
                    
                    ForEach(events) { event in
                        eventCell(event)
                    }
                }
            }
        }
        .padding()
    }
    
    func eventCell(_ event: Event) -> some View {
        
        let duration = event.endDate.timeIntervalSince(event.startDate)
        let height = duration / 60 / 60 * hourHeight
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: event.startDate)
        let minute = calendar.component(.minute, from: event.startDate)
        let offset = Double(hour-7) * (hourHeight)
//                      + Double(minute)/60 ) * hourHeight
        
        print(hour, minute, Double(hour-7) + Double(minute)/60 )

        return VStack(alignment: .leading) {
            Text(event.startDate.formatted(.dateTime.hour().minute()))
            Text(event.title).bold()
        }
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(6)
        .frame(height: height, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.teal)
                .opacity(0.5)
        )
        .padding(.trailing, 30)
        .padding(.leading, 10)
        .offset(x: 30, y: offset + 24)

    }
    
}


func dateFrom(_ day: Int, _ month: Int, _ year: Int, _ hour: Int = 0, _ minute: Int = 0) -> Date {
    let calendar = Calendar.current
    let dateComponents = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)

    return calendar.date(from: dateComponents) ?? .now
}

#Preview {
    TestCalendar()
}
