//
//  SwiftUIView.swift
//  Bordero
//
//  Created by Grande Variable on 21/03/2024.
//

import SwiftUI

struct TVAParametersView: View {
    var body: some View {
        Form {
            Section {
                Toggle(isOn: .constant(true), label: {
                    Text("Appliquer la TVA sur les factures")
                })
            }
            
            Section {
                LabeledContent("Tax label") {
                    
                }
            }
        }
    }
}

#Preview {
    TVAParametersView()
}
