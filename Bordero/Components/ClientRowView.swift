//
//  ClientRowView.swift
//  Bordero
//
//  Created by Grande Variable on 25/04/2024.
//

import SwiftUI

struct ClientRowView: View {
    let firstname : String
    let name : String
    
    var body: some View {
        Label {
            VStack {
                Text(firstname)
                + Text(" ")
                + Text(name)
                    .bold()
            }
        } icon: {
            ProfilImageView(imageData: nil)
        }
    }
}

#Preview {
    ClientRowView(firstname: "AAAAAA", name: "AAAAAA")
}
