//
//  CalendarPageView.swift
//  Bordero
//
//  Created by Grande Variable on 30/07/2024.
//

import SwiftUI

struct CalendarPageView: View {
    let hours: [String]
    @Binding var hourSpacing: Double
    @Binding var hourHeight: Double

    var body: some View {
        VStack(alignment: .leading, spacing: hourSpacing) {
            ForEach(hours, id: \.self) { hour in
                HStack {
                    Text(hour)
                        .font(Font.caption)
                        .minimumScaleFactor(0.7)
                        .frame(width: 35, height: hourHeight, alignment: .trailing)
                        .foregroundColor(.secondary)
                        .dynamicTypeSize(.small ... .large)
                    VStack {
                        Divider()
                            .foregroundColor(.secondary.opacity(0.9))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
