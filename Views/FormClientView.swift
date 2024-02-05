//
//  FormClientView.swift
//  Bordero
//
//  Created by Grande Variable on 05/02/2024.
//

import SwiftUI

struct FormClientView: View {
    
    @Binding var activeSheet: ActiveSheet?
    
    @State var nom : String = ""
    @State var prenom : String = ""
    
    @State var adresse : String = ""
    @State var codePostal : String = ""
    @State var ville : String = ""
    
    @State var numero : String = ""
    @State var email : String = ""
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                Color
                    .white
                    .ignoresSafeArea()
                    .overlay(.ultraThinMaterial)
                
                Form {
                    
                    Section {
                        
                        TextField("Entrer un nom", text: $nom)
                            
                        TextField("Entrer un prénom", text: $prenom)
                    } footer: {
                        Text("Ces champs sont obligatoires.")
                    }
                    
                    Section {
                        
                        TextField("Entrer une adresse", text: $adresse)
                            
                        TextField("Entrer un code postal", text: $codePostal)
                        
                        TextField("Entrer une ville", text: $ville)
                    }
                    
                    Section {
                        TextField("Entrer un numero", text: $numero)
                            
                        TextField("Entrer un email", text: $email)
                    } footer: {
                        Text("Saisir l'un ou l'autre. Idéalement les deux.")
                    }
                    
                }
                .navigationTitle(Text("Nouveau client"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Annuler", role: .destructive) {
                            activeSheet = nil
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("OK") {
                           
                        }
                    }
                }
                
            }
        }
        
    }
}

#Preview {
    FormClientView(activeSheet: .constant(.createClient))
}
