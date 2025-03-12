//
//  ClientRowView.swift
//  Bordero
//
//  Created by Grande Variable on 25/04/2024.
//

import SwiftUI

struct ClientRowView: View {
    
    @Binding var client: Client?
    
    var body: some View {
        Label {
            HStack(spacing: 4) {
                Text(client?.firstname ?? "Le client n'a pas été retrouvé ou bien a été supprimé.")
                
                 Text(client?.lastname ?? "")
                    .bold()
            }
        } icon: {
            Image(systemName: client != nil ? "person.crop.circle.fill" : "person.crop.circle.badge.questionmark.fill")
                .foregroundStyle(.white, .gray)
                .imageScale(.large)
        }
    }
}

#Preview {
    ClientRowView(client: .constant(.example))
}
