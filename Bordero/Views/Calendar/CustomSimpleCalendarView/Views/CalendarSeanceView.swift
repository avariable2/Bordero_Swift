//
//  CalendarSeanceView.swift
//  Bordero
//
//  Created by Thomas Vary on 07/08/2024.
//

import SwiftUI

struct CalendarSeanceView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State private var wantToDelete = false
    @State private var activeSheet : ActiveSheet? = nil
    let seance : Seance
    
    var hourStart : Int {
        return seance.startDate.hour!
    }
    
    var hourEnd : Int {
        hourStart + 3
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(seance.titre)
                    .foregroundStyle(seance.color)
                    .font(.title2)
                    .bold()
                
                Divider()
                
                LabeledContent {
                    Text(seance.typeActes.count.description)
                } label: {
                    Text("Type d'acte(s)")
                        .font(.headline)
                }
                
                ForEach(seance.typeActes) { typeActe in
                    
                    DisplayTypeActeView(text: typeActe.name, price: String(format: "Prix total : %.2f €", typeActe.total))
                    
                    Divider()
                }
                
                LabeledContent("Date de départ", value: seance.startDate.formatted(.dateTime))
                
                LabeledContent("Durée", value: seance.durationConvertie)
                
                Divider()
                
                ZStack(alignment: .topLeading) {
                                    
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(createHourRange(from: seance.startDate.hour!, duration: 3), id: \.self) { hour in
                            HStack {
                                Text("\(hour)")
                                    .font(.caption)
                                    .frame(width: 20, alignment: .trailing)
                                Color.gray
                                    .frame(height: 1)
                            }
                            .frame(height: 50)
                        }
                    }
                    
                    eventCell(seance)
                        .mask(Rectangle())
                }
                .frame(height: 150)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(.quinary)
                        .frame(height: 150)
                )
                
                Divider()
                
                LabeledContent {
                    
                } label: {
                    Text("Commentaire")
                    
                    Text(seance.commentaire.isEmpty ? "Aucun" : seance.commentaire)
                        .foregroundStyle(.secondary)
                    
                }
                
                
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    activeSheet = .modifySeance(seance)
                } label: {
                    Text("Modifier")
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                Button {
                    wantToDelete.toggle()
                } label: {
                    Text("Supprimer l'évènement")
                }
                .padding(.bottom)
            }
        }
        .sheet(item: $activeSheet, content: { activeSheet in
            NavigationStack {
                switch activeSheet {
                case .modifySeance(let seance):
                    FormSeanceSheet(
                        seance: seance,
                        dateDebut: seance.startDate,
                        tabTypeActeWithDuration: seance.typeActes.map({ typeActe in
                            typeActe.getWithDuration()
                        }),
                        client: seance.client_,
                        commentaire: seance.commentaire,
                        bgColor: seance.color
                    )
                default:
                    EmptyView() // IMPOSSIBLE
                }
            }
        })
        .confirmationDialog("Voulez-vous vraiment supprimer cet évènement ?", isPresented: $wantToDelete, titleVisibility: .visible) {
            Button("Supprimer", role: .destructive) {
                moc.delete(seance)
                DataController.saveContext()
                dismiss()
            }
        }
        .navigationTitle("Détails de l'évènement")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.plain)
    }
    
    func createHourRange(from hour: Int, duration: Int) -> Range<Int> {
        return hour..<(hour + duration)
    }
    
    func eventCell(_ event: Seance) -> some View {
        // Calculez la durée de l'événement en minutes
        let durationInMinutes = Double(event.duration_) / 60
        
        // Définir l'échelle : chaque minute correspond à un certain nombre de points
        let pointsPerMinute: CGFloat = 2
        
        // Calculer la hauteur en fonction de la durée
        let height: CGFloat = CGFloat(durationInMinutes) * pointsPerMinute
        
        let maxHeight: CGFloat = 150
        let finalHeight = min(height, maxHeight)
        
//        print("DEBUG_BRO: taille : \(height)")
        
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: event.startDate)
        let offset = (Double(minute) / 60) * 50 + 26

        return VStack(alignment: .leading) {
            Text(event.startDate.formatted(.dateTime.hour().minute()))
            
            Text(event.titre)
                .bold()
        }
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(4)
        .frame(height: finalHeight, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(event.color)
                .opacity(0.7)
        )
        .padding(.trailing, 30)
        .offset(x: 30, y: offset)
    }

}

#Preview {
    NavigationStack {
        CalendarSeanceView(seance: Seance.example)
    }
}
