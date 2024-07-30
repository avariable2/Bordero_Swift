//
//  CalendarTimelineView.swift
//  Bordero
//
//  Created by Grande Variable on 30/07/2024.
//

import SwiftUI

struct CalendarTimelineView: View {
    let startHourOfDay: Int
    @Binding var hourSpacing: Double
    @Binding var hourHeight: Double
    @State private var timelineOffset: Double = 0

    // Timer for updating the position of the timeline
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { _ in
            VStack {
                Divider()
                    .frame(height: 1)
                    .overlay(Color.red)
                    .offset(CGSize(width: 0, height: timelineOffset))
                    .padding(.vertical, 8)
            }
            .padding(.horizontal, 16)
            .onAppear {
                calculateOffset()
            }
        }
        .onReceive(timer) { _ in
            calculateOffset()
        }
    }

    func calculateOffset() {
        let actualHourHeight = hourHeight + hourSpacing
        let heightPerSecond = (actualHourHeight / 60) / 60
        let secondsSinceStartOfDay = abs(Date().atHour(startHourOfDay)?.timeIntervalSinceNow ?? 0)
        timelineOffset = secondsSinceStartOfDay * heightPerSecond
    }
}

