//
//   TextSettingsendClientView.swift
//  Bordero
//
//  Created by Grande Variable on 20/05/2024.
//

import SwiftUI
import UIKit

struct TextSettingsSendClientView : View {
    @State private var titreFacture = "Facture #NUMERO#"
    @State private var bodyMessageFacture = """
Bonjour Client,

Voici votre facture du #DATE_DOCUMENT#.

Cordialement,
#NOM_SOCIETE#
"""
    
    @State private var titreDevis = "Devis #NUMERO#"
    @State private var bodyMessageDevis = """
Bonjour Client,

Voici votre devis du #DATE_DOCUMENT#.

Cordialement,
#NOM_SOCIETE#
"""
    
    var body: some View {
        Form {
            Section("Commandes", isExpanded: .constant(true)) {
                Text("Vous pouvez personnaliser votre message lors de l'envoie des documents. Voici les balises que vous pouvez utilisez : ")
                
                RowCommandeView(titre: "Prix total", commande: "#TOTAL#")
                RowCommandeView(titre: "Date création document", commande: "#DATE_DOCUMENT#")
                RowCommandeView(titre: "Nom du document", commande: "#NOM_DOCUMENT#")
                RowCommandeView(titre: "Numéro du document", commande: "#NUMERO#")
                RowCommandeView(titre: "Nom du client", commande: "#NOM_CLIENT#")
                RowCommandeView(titre: "Nom de l'entreprise", commande: "#NOM_SOCIETE#")
                RowCommandeView(titre: "Personne à contacter", commande: "#CONTACT_SOCIETE#")
                
            }
            
            Section {
                
                HighlightingTextViewRepresentable(text: $titreFacture)
                    .accessibilityLabel("Titre du message pour une facture")
                
                HighlightingTextViewRepresentable(text: $bodyMessageFacture)
                    .frame(minHeight: 140)
                    .accessibilityLabel("Corps du message pour la facture")
            } header : {
                Text("Facture")
            }
            
            Section("Devis") {
                HighlightingTextViewRepresentable(text: $titreDevis)
                    .accessibilityLabel("Titre du message pour un devis")
                
                HighlightingTextViewRepresentable(text: $bodyMessageDevis)
                    .frame(minHeight: 140)
                    .accessibilityLabel("Corps du message pour le devis")
            }
            
            
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Text("Sauvegarder")
                }
            }
        }
    }
}

class HighlightingTextView: UITextView {
    
    override var text: String! {
        didSet {
            highlightTags()
        }
    }
    
    private func highlightTags() {
        let pattern = "#(TOTAL|DATE_DOCUMENT|NOM_DOCUMENT|NUMERO|NOM_CLIENT|NOM_SOCIETE|CONTACT_SOCIETE)#"
        
        guard let text = self.text else { return }
        
        let attributedString = NSMutableAttributedString(string: text)
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = regex.matches(in: text, options: [], range: nsRange)
        
        updateTextColor(for: attributedString)
        
        for match in matches {
            if let range = Range(match.range, in: text) {
                let nsRange = NSRange(range, in: text)
                attributedString.addAttribute(.foregroundColor, value: UIColor.link, range: nsRange)
            }
        }
        
        self.attributedText = attributedString
    }
    
    private func updateTextColor(for attributedString: NSMutableAttributedString) {
        let textColor: UIColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
        attributedString.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: attributedString.length))
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (weakSelf: HighlightingTextView, previousTraitCollection) in
            weakSelf.highlightTags()
        })
    }
        
    private func updateFont() {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        self.font = fontMetrics.scaledFont(for: font)
        highlightTags()
    }
}

struct HighlightingTextViewRepresentable: UIViewRepresentable {
    
    @Binding var text: String
    
    func makeUIView(context: Context) -> HighlightingTextView {
        let textView = HighlightingTextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.backgroundColor = .clear
        return textView
    }
    
    func updateUIView(_ uiView: HighlightingTextView, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: HighlightingTextViewRepresentable
        
        init(_ parent: HighlightingTextViewRepresentable) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

#Preview {
    TextSettingsSendClientView()
}

private struct RowCommandeView : View {
    let titre : String
    let commande : String
    
    var body: some View {
        LabeledContent(titre) {
            Text(commande)
                .foregroundStyle(.link)
        }
    }
}
