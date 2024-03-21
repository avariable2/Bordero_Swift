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
    
    var body: some View {
        HStack {
            
            Image(systemName: systemName)
                 .resizable()
                 .foregroundStyle(color)
                 .frame(width: 25, height: 25)
            
            Text(text)
        }
        
    }
}

#Preview {
    RowIconColor(text: "Abidgen", systemName: "star.square.fill", color: .red)
}
