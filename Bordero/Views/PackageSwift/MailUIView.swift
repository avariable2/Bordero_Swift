//
//  MailUIView.swift
//  Bordero
//
//  Created by Grande Variable on 19/05/2024.
//

import AVFoundation
import Foundation
import SwiftUI
import MessageUI
import UIKit

struct MailUIView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentation
    
    let recipients: [String]?
    let body: String?
    
    let pdfToSend : Data?
    let namePdfToSend : String?
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        
        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(presentation: Binding<PresentationMode>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation,
                           result: $result)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailUIView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        
        vc.setToRecipients(recipients)
        vc.setMessageBody(body ?? "", isHTML: false)
        if let data = pdfToSend {
            vc.addAttachmentData(data, mimeType: "application/pdf", fileName: namePdfToSend ?? "Document")
        }
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailUIView>) {
        
    }
}
