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
                    
                    Text("\(praticien?.firstname ?? "")")
                        + Text(" \(praticien?.lastname ?? "")")
                            .bold()
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                
                Section {
                    NavigationLink {
                        FormPraticienView(isOnBoarding: false, praticien : praticien)
                    } label: {
                        RowIconColor(
                            text: "Vos coordoonées",
                            systemName: "person.crop.square.fill",
                            color: .green
                        )
                    }
                }
                
                Section {
                    NavigationLink {
                        TVAParametersView()
                    } label: {
                        RowIconColor(
                            text: "Paramètres TVA",
                            systemName: "tag.square.fill",
                            color: .orange
                        )
                    }
                    .disabled(true)
                    
                    NavigationLink {
                        
                    } label: {
                        RowIconColor(
                            text: "Options de paiement",
                            systemName: "eurosign.square.fill",
                            color: .black
                        )
                    }
                } header: {
                    Text("Paramètres de facturation")
                }
                
                
                Section("Documents") {
                    NavigationLink {
                        ModeleDocumentView()
                    } label: {
                        RowIconColor(
                            text: "Paramètres du modèle",
                            systemName: "lightswitch.on.square.fill",
                            color: .blue
                        )
                    }
                    
                    NavigationLink {
                        
                    } label: {
                        RowIconColor(
                            text: "Rappel et Email avec le client",
                            systemName: "bell.square.fill",
                            color: .red
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



#Preview {
    ParametersView(activeSheet: .constant(nil))
}
