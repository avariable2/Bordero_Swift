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
//                
//                Text("Client")
//                    .font(.headline)
//                    .padding(.bottom, 4)
//                
//                ClientRowView(client: .constant(seance.client_))
//                
//                Divider()
                
                LabeledContent {
                    Text("\(seance.typeActes.count.description)")
                } label: {
                    Text("Type d'acte(s)")
                        .font(.headline)
                }
                
                ForEach(seance.typeActes) { typeActe in
//                    Text(typeActe.name)
//                        .foregroundStyle(seance.color)
                    
                    DisplayTypeActeView(text: typeActe.name, price: String(format: "Prix total : %.2f €", typeActe.total))
                    
                    Divider()
                }
                
                LabeledContent("Date de départ", value: seance.startDate.formatted(.dateTime))
                
                LabeledContent("Durée", value: seance.durationConvertie)
                
                
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
                        .clipped()
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
                    
                    Text("\(seance.commentaire)")
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
        let height : CGFloat = CGFloat(seance.duration_ / 60 / 60 * 50)
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: event.startDate)
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
        .frame(height: height, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(seance.color)
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
