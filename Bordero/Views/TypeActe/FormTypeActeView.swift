//
//  FormTypeActeView.swift
//  Bordero
//
//  Created by Grande Variable on 26/03/2024.
//

import SwiftUI

struct FormTypeActeView: View {
    
    @State private var showSuccess = false
    
    var body: some View {
        VStack {
            FormTypeActeSheet(onSave: {
                showSuccess = true
            })
            
            if showSuccess {
                Text("Votre type d'acte a bien été enregistré.")
            }
        }
    }
}

#Preview {
    FormTypeActeView()
}
