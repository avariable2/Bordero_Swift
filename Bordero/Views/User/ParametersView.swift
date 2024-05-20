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
                }
                .font(.title)
                .bold()
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
                            color: .green,
                            accessibility: "Bouton pour modifier vos informations personnels"
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
                            color: .orange,
                            accessibility: "Bouton pour changer les paramètres de T.V.A"
                        )
                    }
                    .disabled(true)
                    
                    NavigationLink {
                        
                    } label: {
                        RowIconColor(
                            text: "Options de paiement",
                            systemName: "eurosign.square.fill",
                            color: .black,
                            accessibility: "Bouton pour definir vos options de paiement"
                        )
                    }
                    .disabled(true)
                } header: {
                    Text("Paramètres de facturation")
                } footer: {
                    Text("🏗️ En construction. Disponible dans une future mise à jour.")
                }
                
                Section("Documents") {
                    NavigationLink {
                        if let praticien = praticien {
                            ModeleDocumentView(praticien: praticien)
                        }
                    } label: {
                        RowIconColor(
                            text: "Paramètres du modèle",
                            systemName: "lightswitch.on.square.fill",
                            color: .purple,
                            accessibility: "Bouton pour modifier les options de votre facture"
                        )
                    }
                    .disabled(praticien == nil)
                    
                    NavigationLink {
                        TextSettingsSendClientView()
                            .navigationTitle("Gérer les messages")
                    } label: {
                        RowIconColor(
                            text: "Contact avec le client",
                            systemName: "square.text.square.fill",
                            color: .brown,
                            accessibility: "Bouton pour automatiser vos envoies de document"
                        )
                    }
                    
                    NavigationLink {
                        
                    } label: {
                        RowIconColor(
                            text: "Notifications",
                            systemName: "bell.square.fill",
                            color: .red,
                            accessibility: "Bouton pour configurer les rappels de factures impayées"
                        )
                    }
                }
                
                if ProcessInfo.processInfo.isiOSAppOnMac {
                    
                    Section {
                        Text("Si un problème survient contacter le développeur avec cette adresse : feuilles.neutron_0i@icloud.com")
                            .contextMenu {
                                Button(action: {
                                    UIPasteboard.general.string = "feuilles.neutron_0i@icloud.com"
                                }) {
                                    Text("Copier")
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                    } footer: {
                        Text("Maintener le texte pour copier l'email.")
                    }
                    
                } else {
                    Section {
                        Button {
                            isShowingMailView.toggle()
                        } label: {
                            Label(
                                title: {
                                    Text("Contacter le développeur")
                                },
                                icon: {
                                    Image(systemName: "person.crop.square.filled.and.at.rectangle.fill")
                                        .foregroundStyle(.white, .blue)
                                }
                            )
                        }
                        .disabled(!MFMailComposeViewController.canSendMail())
                        .sheet(isPresented: $isShowingMailView) {
                            DevelopperMailView(result: self.$result)
                                .edgesIgnoringSafeArea(.bottom)
                        }
                        
                    } footer: {
                        if !MFMailComposeViewController.canSendMail() {
                            Text("Vous ne pouvez envoyer de e-mail depuis cette appareil")
                        }
                    }
                   
                }
                
                if !DataController.getStatusiCloud() {
                    Section {
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString),
                               UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Text("Activé la synchronisation iCloud ")
                        }
                    } footer: {
                        VStack(alignment: .leading) {
                            Text("Données Bordero non synchronisées \nVous pouvez activer la synchronisation de vos données Bordero dans les réglages iCloud.")
                        }
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
    ParametersView(activeSheet: .constant(nil), praticien: Praticien.example)
}
