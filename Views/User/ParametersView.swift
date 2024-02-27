//
//  ParameterView.swift
//  Bordero
//
//  Created by Grande Variable on 27/02/2024.
//

import SwiftUI

struct ParametersView: View {
    @Binding var activeSheet : ActiveSheet?
    @State var praticien : Praticien?
    
    var body: some View {
        NavigationStack {
            Form {
                
                VStack(alignment: .center, spacing: 20) {
                    
                    ProfilImageView(imageData: praticien?.profilPicture)
                        .frame(height: 80)
                        .font(.system(size: 60))
                        .shadow(radius: 5)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                
                Section {
                    NavigationLink {
                        FormPraticienView(isOnBoarding: false, praticien : praticien)
                    } label: {
                        RowParameter(
                            text: "Vos coordoonées",
                            systemName: "creditcard",
                            color: .green
                        )
                    }
                }
                
                Section {
                    NavigationLink {
                        
                    } label: {
                        RowParameter(
                            text: "Paramètres TVA",
                            systemName: "percent",
                            color: .red
                        )
                    }
                    
                    NavigationLink {
                        
                    } label: {
                        RowParameter(
                            text: "Options de paiement",
                            systemName: "creditcard",
                            color: .green
                        )
                    }
                } header: {
                    Text("Paramètres de facturation")
                }
                
                
                Section("Documents") {
                    NavigationLink {
                        
                    } label: {
                        RowParameter(
                            text: "Paramètres du modèle",
                            systemName: "doc",
                            color: .blue
                        )
                    }
                    
                    NavigationLink {
                        
                    } label: {
                        RowParameter(
                            text: "Options de paiement",
                            systemName: "creditcard",
                            color: .green
                        )
                    }
                }
            }
//            .onAppear {
//                self.praticien = PraticienUtils.shared.praticien
//            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        activeSheet = nil
                    } label: {
                        Text("OK")
                    }
                }
            }
            .headerProminence(.increased)
        }
    }
}

struct RowParameter :View {
    
    var text : String
    var systemName : String
    var color : Color
    
    var body: some View {
//        Label {
//            Text(text)
//        } icon: {
//            Image(systemName: systemName)
//                .imageScale(.medium)
//                .foregroundStyle(.white)
//                .background(
//                    RoundedRectangle(cornerRadius: 2)
//                        .foregroundColor(color)
//                )
//                
//        }
        Text(text)
    }
}

#Preview {
    ParametersView(activeSheet: .constant(nil))
}
