//
//  FormClientView.swift
//  Bordero
//
//  Created by Grande Variable on 26/03/2024.
//

import SwiftUI

struct FormClientView: View {
    
    @State private var showSuccess = false
    
    var body: some View {
        VStack {
            FormClientSheet(onSave: {
                showSuccess = true
            })
        }
    }
}

#Preview {
    FormClientView()
}
