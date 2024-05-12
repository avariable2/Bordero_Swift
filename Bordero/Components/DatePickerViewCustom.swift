//
//  DatePickerViewCustom.swift
//  Bordero
//
//  Created by Grande Variable on 12/04/2024.
//

import SwiftUI

struct DatePickerViewCustom: View {
    let text : String
    @Binding var selection : Date
    var body: some View {
        ViewThatFits {
            LabeledContent(text) {
                DatePicker("",
                   selection: $selection,
                   displayedComponents: .date
                )
            }
            
            VStack(alignment: .center) {
                Text(text)
                    .multilineTextAlignment(.center)
                
                DatePicker("",
                   selection: $selection,
                   displayedComponents: .date
                )
                .datePickerStyle(.graphical)
            }
        }
    }
}

#Preview {
    DatePickerViewCustom(text: "Date échéance", selection: .constant(Date()))
}
