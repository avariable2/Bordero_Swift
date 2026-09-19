//
//  TotalStatsView.swift
//  Bordero
//
//  Created by Grande Variable on 18/09/2026.
//

import SwiftUI

struct TotalStatsView: View {
    let title : String
    var totalNumber : Int
    var amount : Float
    var progress : Float
    var color : Color = .purple
    
    private let systemCurrency = Locale.current.currency?.identifier ?? "EUR"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(totalNumber, format: .number)
                    .font(.headline)
                    .foregroundStyle(color)
            }
            
            Text(amount, format: .currency(code: systemCurrency))
                .font(.title2)
                .bold()
            
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(color)
        }
        .frame(maxHeight: .infinity)
        .padding(20)
        .background()
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        
        
        
    }
}

#Preview {
    TotalStatsView(title: "Total", totalNumber: 8, amount: 9450, progress: 0.4)
    .padding(.horizontal, 150)
    .background(.fill)
        
}
