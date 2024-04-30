//
//  DataValueView.swift
//  Bordero
//
//  Created by Grande Variable on 30/04/2024.
//

import SwiftUI

struct DataValueView: View {
    var value: String
    var unit: String
    
    @ScaledMetric var size: CGFloat = 1
    
    @ViewBuilder var body: some View {
        HStack {
            Text(value).font(.system(size: 24 * size, weight: .bold, design: .rounded)) + Text(" \(unit)").font(.system(size: 14 * size, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
            Spacer()
        }
    }
}

#Preview {
    DataValueView(value: "60", unit: "euro")
}
