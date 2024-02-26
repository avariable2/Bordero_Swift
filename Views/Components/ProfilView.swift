//
//  ProfilView.swift
//  Bordero
//
//  Created by Grande Variable on 26/02/2024.
//

import SwiftUI
import CoreData

struct ProfilView: View {
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(sortDescriptors: []) var praticien : FetchedResults<Praticien>
    
    var body: some View {
        NavigationLink {
            FormPraticienView(isOnBoarding: false)
        } label: {
            if let data = praticien.first?.profilPicture, let uiImage = UIImage(data: data)  {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .clipShape(Circle())
                
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .foregroundStyle(.white, .gray)
                    .imageScale(.large)
            }
        }
    }
}

#Preview {
    ProfilView()
}
