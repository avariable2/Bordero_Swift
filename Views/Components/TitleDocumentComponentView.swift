//
//  TitleDocumentComponentView.swift
//  Bordero
//
//  Created by Grande Variable on 24/02/2024.
//

import SwiftUI

struct TitleDocumentComponentView : View {
    enum TypeDoc : String, CaseIterable, Identifiable {
        case facture, devis
        
        var id: Self { self }
    }
    
    @State var numero : String = "001"
    @State var typeSelected : TypeDoc = .facture
    @FocusState private var numberFactureIsFocused: Bool
    @State private var isOn : Bool = true
    @State private var showSheet = false
    
    var body: some View {
        HStack {
//            Toggle(isOn: $isOn){
//                Text(isOn == true ? "Facture" : "Devis")
//            }
//            .toggleStyle(.button)
//            .font(.largeTitle)
//            .labelsHidden()
//            .padding(.trailing)
            
            Picker("", selection: $typeSelected) {
                ForEach(TypeDoc.allCases) { type in
                    Text(type.rawValue.capitalized)
                        .font(.title)
                }
            }
            .pickerStyle(.segmented)
            
             
             TextField("A001", text: $numero)
                .textFieldStyle(.roundedBorder)
                .focused($numberFactureIsFocused)
                .frame(width: 150)
                .font(.largeTitle)
            
            Spacer()
            
            Button {
                showSheet = true
            } label: {
                Image(systemName: "info.circle")
                    .foregroundColor(.accentColor)
                    .imageScale(.large
                    )
            }
            .sheet(isPresented: $showSheet, content: {
//                SheetDetail(showingSheet: $showSheet)
            })
            
        }
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        
        .toolbar {
//            ToolbarItem(placement: .keyboard) {
//                ButtonWithAnimation(text: "Facture") {
//                    type = .facture
//                }
//            }
//            
//            ToolbarItem(placement: .keyboard) {
//                ButtonWithAnimation(text: "Devis") {
//                    type = .devis
//                }
//            }
//            
            ToolbarItem(placement: .keyboard) {
                ButtonWithAnimation(text: "OK") {
                    numberFactureIsFocused = false
                }
            }
        }
    }
}

struct ButtonWithAnimation : View {
    
    var text : String
    var action : () -> Void
    
    var body: some View {
        Button {
            withAnimation(.easeIn) {
                action()
            }
        } label: {
            Text(text)
        }
    }
}

#Preview {
    TitleDocumentComponentView()
}
