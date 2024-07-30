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
        
        return VStack {
            VStack(alignment: .leading) {
                if (event.calendarActivity.duration / 60) <= 30 {
                    if event.columnCount > 0 {
                        HStack(alignment: .center) {
                            Text(event.calendarActivity.title)
                                .foregroundColor(mainColor)
                                .font(.caption)
                                .padding(.top, 4)
                                .fontWeight(.semibold)
                                .dynamicTypeSize(.small ... .large)
                            Spacer()
                            Text("\(event.startDate.formatted(date: .omitted, time: .shortened)), \(Int(event.calendarActivity.duration / 60)) min")
                                .foregroundColor(mainColor)
                                .font(.caption2)
                                .dynamicTypeSize(.small ... .large)
                        }
                    } else {
                        HStack(alignment: .center) {
                            Text(event.calendarActivity.title)
                                .foregroundColor(mainColor)
                                .font(.caption)
                                .padding(.top, 4)
                                .fontWeight(.semibold)
                                .dynamicTypeSize(.small ... .large)
                            Spacer()
                            Text("\(event.startDate.formatted(date: .omitted, time: .shortened)) - \(endDate.formatted(date: .omitted, time: .shortened)), \(Int(event.calendarActivity.duration / 60)) min")
                                .foregroundColor(mainColor)
                                .font(.caption2)
                                .dynamicTypeSize(.small ... .large)
                        }
                    }
                } else if (event.calendarActivity.duration / 60) <= 60 {
                    Text(event.calendarActivity.title)
                        .foregroundColor(mainColor)
                        .font(.caption)
                        .padding(.top, 4)
                        .fontWeight(.semibold)
                        .dynamicTypeSize(.small ... .large)
                    if event.columnCount > 0 {
                        Text("\(event.startDate.formatted(date: .omitted, time: .shortened)), \(Int(event.calendarActivity.duration / 60)) min")
                            .foregroundColor(mainColor)
                            .font(.caption2)
                            .dynamicTypeSize(.small ... .large)
                    } else {
                        Text("\(event.startDate.formatted(date: .omitted, time: .shortened)) - \(endDate.formatted(date: .omitted, time: .shortened)), \(Int(event.calendarActivity.duration / 60)) min")
                            .foregroundColor(mainColor)
                            .font(.caption2)
                            .dynamicTypeSize(.small ... .large)
                    }
                } else {
                    Text(event.calendarActivity.title)
                        .foregroundColor(mainColor)
                        .font(.caption)
                        .padding(.top, 4)
                        .fontWeight(.semibold)
                        .dynamicTypeSize(.small ... .large)
                    Text("\(event.startDate.formatted(date: .omitted, time: .shortened)) - \(endDate.formatted(date: .omitted, time: .shortened))")
                        .foregroundColor(mainColor)
                        .font(.caption2)
                        .dynamicTypeSize(.small ... .large)
                    Text("Duration: \(Int(event.calendarActivity.duration / 60)) min")
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
}
