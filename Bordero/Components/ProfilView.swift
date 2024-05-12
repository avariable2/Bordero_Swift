//
//  ProfilView.swift
//  Bordero
//
//  Created by Grande Variable on 26/02/2024.
//

import SwiftUI
import CoreData

struct ProfilImageView: View {
    var imageData: Data?

    var body: some View {
        if let data = imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
            
        } else {
            Image(systemName: "person.crop.circle.fill")
                .foregroundStyle(.white, .gray)
                .imageScale(.large)
                
        }
    }
}

struct ProfilNavigationLink: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var praticien: FetchedResults<Praticien>
    var text: String?

    var body: some View {
        NavigationLink {
            if let firstPraticien = praticien.first {
                FormPraticienView(isOnBoarding: false, praticien: firstPraticien)
            }
        } label: {
            HStack {
                ProfilImageView(imageData: praticien.first?.profilPicture)

                if let text = text {
                    Text(text)
                }
            }
        }
    }
}

#Preview {
    ProfilImageView()
}
