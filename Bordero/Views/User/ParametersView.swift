//
//  ParameterView.swift
//  Bordero
//
//  Created by Grande Variable on 27/02/2024.
//

import SwiftUI
import MessageUI
import CoreData

struct ParametersView: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\Praticien.modificationDate)]
        
    ) var praticien: FetchedResults<Praticien>
    
    @Binding var activeSheet : ActiveSheet?
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    
    @State private var firstPraticien: Praticien?
    
    var body: some View {
        NavigationStack {
            Form {
                #if DEBUG
                Section("Debug") {
                    Text("Nbr de praticien = \(praticien.count)")
                }
                #endif
                
                VStack(alignment: .center, spacing: 20) {
                    ProfilImageView(imageData: firstPraticien?.profilPicture)
                        .frame(height: 80)
                        .font(.system(size: 60))
                        .shadow(radius: 5)
                    
                    Text("\(firstPraticien?.firstname ?? "")")
                        + Text(" \(firstPraticien?.lastname ?? "")")
                }
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                
                Section("Votre société") {
                    NavigationLink {
                        if let firstPraticien {
                            FormPraticienView(praticien: firstPraticien)
                        }
                    } label: {
                        RowIconColor(
                            text: "Vos coordonnées",
                            systemName: "person.crop.square.fill",
                            color: .green,
                            accessibility: "Bouton pour modifier vos informations personnelles"
                        )
                    }
                    
                    NavigationLink {
                        ListTypeActe()
                    } label: {
                        RowIconColor(
                            text: "Vos types d'actes",
                            systemName: "heart.square.fill",
                            color: .purple,
                            accessibility: "Bouton pour modifier vos informations personnelles"
                        )
                    }
                }
                
                Section("Documents") {
                    NavigationLink {
                        if let firstPraticien {
                            ModeleDocumentView(praticien: firstPraticien)
                        }
                       
                    } label: {
                        RowIconColor(
                            text: "Paramètres du modèle",
                            systemName: "lightswitch.on.square.fill",
                            color: .gray,
                            accessibility: "Bouton pour modifier les options de votre facture"
                        )
                    }
                    
                    NavigationLink {
                        if let firstPraticien {
                            TextSettingsSendClientView(praticien: firstPraticien)
                                .navigationTitle("Gérer les messages")
                        }
                    } label: {
                        RowIconColor(
                            text: "Contact avec le client",
                            systemName: "square.text.square.fill",
                            color: .brown,
                            accessibility: "Bouton pour automatiser vos envois de documents"
                        )
                    }
                    
                    NavigationLink {
                        if let firstPraticien {
                            NotificationSettingsView(
                                praticien: firstPraticien,
                                activeNotifications: firstPraticien.hasAcceptNotification
                                
                            )
                        }
                    } label: {
                        RowIconColor(
                            text: "Notifications",
                            systemName: "bell.square.fill",
                            color: .red,
                            accessibility: "Bouton pour configurer les rappels de factures impayées"
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
                
                if ProcessInfo.processInfo.isiOSAppOnMac {
                    
                    Section {
                        Text("Si un problème survient, contactez le développeur avec cette adresse : feuilles.neutron_0i@icloud.com")
                            .contextMenu {
                                Button(action: {
                                    UIPasteboard.general.string = "feuilles.neutron_0i@icloud.com"
                                }) {
                                    Text("Copier")
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                    } footer: {
                        Text("Maintenir le texte pour copier l'email.")
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
                            Text("Vous ne pouvez pas envoyer d'email depuis cette appareil")
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
                            Text("Activer la synchronisation iCloud ")
                        }
                    } footer: {
                        VStack(alignment: .leading) {
                            Text("Données Bordero non synchronisées \nVous pouvez activer la synchronisation de vos données Bordero dans les réglages iCloud.")
                        }
                    }
                }
            }
            .headerProminence(.increased)
            .onAppear() {
                checkIfAlreadyExist()
            }
            .onChange(of: praticien.count) { oldValue, newValue in
                firstPraticien = praticien.first
            }
        }
    }

    
    func checkIfAlreadyExist() {
        let results = praticien
        if results.count > 0 {
            firstPraticien = results.first
        } else {
            firstPraticien = Praticien(context: moc)
        }
    }
}

#Preview {
    ParametersView(activeSheet: .constant(nil))
}



