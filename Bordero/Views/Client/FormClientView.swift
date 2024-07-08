//
//  FormClientView.swift
//  Bordero
//
//  Created by Grande Variable on 26/03/2024.
//

import SwiftUI
import MijickPopupView

struct FormClientView: View {
    
    @State private var showSuccess = false
    
    var body: some View {
        VStack {
            FormClientSheet(onSave: {
                showSuccess = true
            })
            
            if showSuccess {
                BottomCustomPopup()
                    .showAndStack()
                    .dismissAfter(5)
            }
        }
    }
}

struct BottomCustomPopup: BottomPopup {
    func createContent() -> some View {
        HStack(spacing: 0) {
            Text("Votre nouveau client est disponible dans la liste des clients.")
            Spacer()
            Button(action: dismiss) { Text("Fermer") }
        }
        .padding(.vertical, 20)
        .padding(.leading, 24)
        .padding(.trailing, 16)
    }
    
    func configurePopup(popup: BottomPopupConfig) -> BottomPopupConfig {
        popup
            .horizontalPadding(20)
            .bottomPadding(42)
            .cornerRadius(16)
    }
}

#Preview {
    FormClientView()
}
