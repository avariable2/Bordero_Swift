//
//  EventDetailsView.swift
//  Bordero
//
//  Created by Grande Variable on 30/07/2024.
//

import SwiftUI
import SimpleCalendar

struct EventDetailsView: View {
    let event: any CalendarEventRepresentable

    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(event.calendarActivity.activityType.name)
                        .font(.caption)
                        .foregroundColor(event.calendarActivity.activityType.color)
                        .fontWeight(.light)
                    HStack {
                        Circle()
                            .fill(event.calendarActivity.activityType.color)
                            .frame(width: 7)
                        Text(event.calendarActivity.title)
                            .font(.title)
                    }
                    .padding(.bottom, 8)
                    HStack {
                        Text(event.startDate.formatted())
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(event.startDate.relativeDateDisplay())
                            .font(.caption)
                    }
                    Text(event.calendarActivity.description)
                        .padding(.vertical, 20)
                        .font(.body)
                        .fontWeight(.light)
                        .dynamicTypeSize(DynamicTypeSize.small ... DynamicTypeSize.large)
                    if !event.calendarActivity.mentors.isEmpty {
                        Text("Mentors")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        ForEach(event.calendarActivity.mentors, id: \.self) { mentor in
                            Text(mentor)
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding()
    }
}
