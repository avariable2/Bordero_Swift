//
//  RowIconColor.swift
//  Bordero
//
//  Created by Grande Variable on 21/03/2024.
//

import SwiftUI

struct RowIconColor :View {
    var text : String
    var systemName : String
    var color : Color
    
    var accessibility : String
    
    var body: some View {
        HStack {
            
            Image(systemName: systemName)
                 .resizable()
                 .foregroundStyle(.white, color)
                 .frame(width: 25, height: 25)
            
            // Affiche un label Content pour copier facilement les elements mit dedans
            LabeledContent(accessibility) {
                Text(text)
            }
            .labelsHidden()
        }
        
    }
}

#Preview {
    RowIconColor(text: "Abidgen", systemName: "star.square.fill", color: .red, accessibility: "")
}
