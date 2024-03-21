//
//  ParameterView.swift
//  Bordero
//
//  Created by Grande Variable on 27/02/2024.
//

import SwiftUI
import MessageUI

struct ParametersView: View {
    @Binding var activeSheet : ActiveSheet?
    @State var praticien : Praticien?
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    
    var body: some View {
        NavigationStack {
            Form {
                
                VStack(alignment: .center, spacing: 20) {
                    
                    ProfilImageView(imageData: praticien?.profilPicture)
                        .frame(height: 80)
                        .font(.system(size: 60))
                        .shadow(radius: 5)
                    
                    Text(praticien?.firstname ?? "")
                        + Text(praticien?.lastname ?? "")
                            .bold()
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
                        TVAParametersView()
                    } label: {
                        RowParameter(
                            text: "Paramètres TVA",
                            systemName: "percent",
                            color: .red
                        )
                    }
                    .disabled(true)
                    
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
                        ModeleDocumentView()
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
                            text: "Rappel et Email avec le client",
                            systemName: "creditcard",
                            color: .green
                        )
                    }
                    .disabled(true)
                }
                
                Section {
                    Button {
                        isShowingMailView.toggle()
                    } label: {
                        Label(
                            title: {
                                Text("Contacter le développeur")
                            },
                            icon: {
                                Image(systemName: "person.bubble")
                                    .foregroundStyle(.blue, .gray)
                            }
                        )
                    }
                    .disabled(!MFMailComposeViewController.canSendMail())
                    .sheet(isPresented: $isShowingMailView, onDismiss: nil) {
                        MailView(isShowing: self.$isShowingMailView, result: self.$result)
                            .edgesIgnoringSafeArea(.bottom)
                    }
                    
                } footer: {
                    if !MFMailComposeViewController.canSendMail() {
                        Text("Vous ne pouvez envoyer de e-mail depuis cette appareil")
                    }
                }

            }
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
        Text(text)
    }
}

#Preview {
    ParametersView(activeSheet: .constant(nil))
}
