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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(seance.titre)
                    .font(.title2)
                    .bold()
                
                ForEach(seance.typeActes) { typeActe in
                    Text(typeActe.name)
                        .foregroundStyle(seance.color)
                }
                
                Divider()
                
                ClientRowView(client: .constant(seance.client_))
                
                Divider()
                
                LabeledContent("Date de départ", value: seance.startDate.formatted(.dateTime))
                
                LabeledContent("Durée", value: seance.durationConvertie)
                
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
}

#Preview {
    NavigationStack {
        CalendarSeanceView(seance: Seance.example)
    }
}
