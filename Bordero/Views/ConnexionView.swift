//
//  ContentView.swift
//  Bordero
//
//  Created by Grande Variable on 28/01/2024.
//

import SwiftUI
import _AuthenticationServices_SwiftUI

struct ConnexionView: View {
    var body: some View {
        VStack {
            Image("Logo")
                .resizable()
                .imageScale(.large)
                .foregroundStyle(.tint)
                .frame(height: 300)
            
            Text("Bienvenue \nsur votre assistant pour la gestion de vos factures")
                .font(.title)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success(_):
                        print("Authorisation successful")
                    case .failure(let error):
                    print("Authorisation failed: \(error.localizedDescription)")
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
        }
        .padding()
    }
}

#Preview {
    ConnexionView()
}
