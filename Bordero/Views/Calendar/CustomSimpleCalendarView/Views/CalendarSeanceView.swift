//
//  CalendarSeanceView.swift
//  Bordero
//
//  Created by Thomas Vary on 07/08/2024.
//

import SwiftUI

struct CalendarSeanceView: View {
    
    let seance : Seance
    
    var body: some View {
        VStack {
            Text(seance.titre)
                .font(.title3)
            
            LabeledContent("Date de départ", value: seance.startDate.formatted(.dateTime))
            
            Text(seance.commentaire)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Détail de l'événement")
    }
}

#Preview {
    CalendarSeanceView(seance: Seance.example)
}
