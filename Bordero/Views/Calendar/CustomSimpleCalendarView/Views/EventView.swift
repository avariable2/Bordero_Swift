//
//  EventView.swift
//  Bordero
//
//  Created by Grande Variable on 30/07/2024.
//

import SwiftUI
import SimpleCalendar

struct EventView: View {
    let event: any CalendarEventRepresentable
    let selectionAction: SelectionAction
    
    // For opening Event details
    @State private var showEventSheet = false
    
    var body: some View {
        VStack {
            if case .destination(let customView) = selectionAction {
                NavigationLink {
                    AnyView(customView(event))
                } label: {
                    content
                }
            } else {
                content
                    .onTapGesture {
                        switch selectionAction {
                        case .sheet, .customSheet:
                            showEventSheet = true
                        case .inform(let closure):
                            closure(event)
                        default:
                            break
                        }
                    }
                    .sheet(isPresented: $showEventSheet) {
                        ZStack {
                            if case .customSheet(let customView) = selectionAction {
                                AnyView(customView(event))
                            } else {
                                EventDetailsView(event: event)
                            }
                        }
                        .presentationDetents([.medium])
                    }
            }
        }
    }
    
    private var content: some View {
        let mainColor = event.calendarActivity.activityType.color
        let endDate = event.startDate.addingTimeInterval(event.calendarActivity.duration)
        let durationMinutes = Int(event.calendarActivity.duration / 60)
        let formattedStartTime = event.startDate.formatted(date: .omitted, time: .shortened)
        let formattedEndTime = endDate.formatted(date: .omitted, time: .shortened)
        
        return VStack {
            VStack(alignment: .leading) {
                
                Text(event.calendarActivity.title)
                    .foregroundColor(mainColor)
                    .font(.body)
                    .padding(.top, 6)
                    .fontWeight(.semibold)
                
                if durationMinutes <= 30 {
                    eventTimeView(mainColor: mainColor, startTime: formattedStartTime, endTime: formattedEndTime, durationMinutes: durationMinutes)
                } else if durationMinutes <= 60 {
                    eventTimeView(mainColor: mainColor, startTime: formattedStartTime, endTime: formattedEndTime, durationMinutes: durationMinutes, isShortDuration: false)
                } else {
                    Text("\(formattedStartTime) - \(formattedEndTime)")
                        .foregroundColor(mainColor)
                        .font(.caption2)
                        .dynamicTypeSize(.small ... .large)
                    Text("Duration: \(durationMinutes) min")
                        .foregroundColor(mainColor)
                        .font(.caption2)
                        .dynamicTypeSize(.small ... .large)
                }
                Spacer()
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .background(mainColor.opacity(0.30), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                HStack {
                    Rectangle()
                        .fill(mainColor)
                        .frame(maxHeight: .infinity, alignment: .leading)
                        .frame(width: 4)
                    Spacer()
                }
            }
        }
        .foregroundColor(.primary)
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(mainColor, lineWidth: 1)
                .frame(maxHeight: .infinity)
        }
        .mask(
            RoundedRectangle(cornerRadius: 6)
                .frame(maxHeight: .infinity)
        )
    }

    @ViewBuilder
    private func eventTimeView(mainColor: Color, startTime: String, endTime: String, durationMinutes: Int, isShortDuration: Bool = true) -> some View {
        if event.columnCount > 0 {
            Text("\(startTime), \(durationMinutes) min")
                .foregroundColor(mainColor)
                .font(.caption2)
                .dynamicTypeSize(.small ... .large)
        } else {
            Text("\(startTime) - \(endTime), \(durationMinutes) min")
                .foregroundColor(mainColor)
                .font(.caption2)
                .dynamicTypeSize(.small ... .large)
        }
    }
    
//    private var content: some View {
//        let mainColor = event.calendarActivity.activityType.color
//        let endDate = event.startDate.addingTimeInterval(event.calendarActivity.duration)
//        let durationMinutes = Int(event.calendarActivity.duration / 60)
//        let formattedStartTime = event.startDate.formatted(date: .omitted, time: .shortened)
//        let formattedEndTime = endDate.formatted(date: .omitted, time: .shortened)
//        
//        return VStack {
//            VStack(alignment: .leading) {
//                
//                Text(event.calendarActivity.title)
//                    .foregroundColor(mainColor)
//                    .font(.body)
//                    .padding(.top, 6)
//                    .fontWeight(.semibold)
//                
//                if durationMinutes <= 30 {
//                    eventTimeView(mainColor: mainColor, startTime: formattedStartTime, endTime: formattedEndTime, durationMinutes: durationMinutes)
//                } else if durationMinutes <= 60 {
//                    eventTimeView(mainColor: mainColor, startTime: formattedStartTime, endTime: formattedEndTime, durationMinutes: durationMinutes, isShortDuration: false)
//                } else {
//                    Text("\(formattedStartTime) - \(formattedEndTime)")
//                        .foregroundColor(mainColor)
//                        .font(.caption2)
//                        .dynamicTypeSize(.small ... .large)
//                    Text("Duration: \(durationMinutes) min")
//                        .foregroundColor(mainColor)
//                        .font(.caption2)
//                        .dynamicTypeSize(.small ... .large)
//                }
//                Spacer()
//            }
//            .padding(.horizontal, 8)
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
//            .background(.ultraThinMaterial)
//            .background(mainColor.opacity(0.30), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
//            .overlay {
//                HStack {
//                    Rectangle()
//                        .fill(mainColor)
//                        .frame(maxHeight: .infinity, alignment: .leading)
//                        .frame(width: 4)
//                    Spacer()
//                }
//            }
//        }
//        .foregroundColor(.primary)
//        .overlay {
//            RoundedRectangle(cornerRadius: 6)
//                .stroke(mainColor, lineWidth: 1)
//                .frame(maxHeight: .infinity)
//        }
//        .mask(
//            RoundedRectangle(cornerRadius: 6)
//                .frame(maxHeight: .infinity)
//        )
//    }
//
//    @ViewBuilder
//    private func eventTimeView(mainColor: Color, startTime: String, endTime: String, durationMinutes: Int, isShortDuration: Bool = true) -> some View {
//        if event.columnCount > 0 {
//            Text("\(startTime), \(durationMinutes) min")
//                .foregroundColor(mainColor)
//                .font(.caption2)
//                .dynamicTypeSize(.small ... .large)
//        } else {
//            Text("\(startTime) - \(endTime), \(durationMinutes) min")
//                .foregroundColor(mainColor)
//                .font(.caption2)
//                .dynamicTypeSize(.small ... .large)
//        }
//    }

}
