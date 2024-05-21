//
//  MessageUIView.swift
//  Bordero
//
//  Created by Grande Variable on 19/05/2024.
//

import MessageUI
import SwiftUI

struct MessageComposeView: UIViewControllerRepresentable {
    typealias Completion = (_ messageSent: Bool) -> Void

    static var canSendText: Bool { MFMessageComposeViewController.canSendText() }
        
    let recipients: [String]?
    let body: String?
    
    let pdfToSend : Data?
    let namePdfToSend : String?
    
    let completion: Completion?
    
    func makeUIViewController(context: Context) -> UIViewController {
        guard Self.canSendText else {
            let errorView = MessagesUnavailableView()
            return UIHostingController(rootView: errorView)
        }
        
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = context.coordinator
        controller.recipients = recipients
        
        if let data = pdfToSend {
            controller.addAttachmentData(data, typeIdentifier: "public.content", filename: namePdfToSend ?? "Document")
        }
        
        controller.body = body
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: self.completion)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        private let completion: Completion?

        public init(completion: Completion?) {
            self.completion = completion
        }
        
        public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true, completion: nil)
            completion?(result == .sent)
        }
    }
}

struct MessagesUnavailableView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            ContentUnavailableView("Messages n'est pas disponible avec votre appareil", systemImage: "xmark.circle")
                
        }.toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Text("Annuler")
                }
            }
        }
        
    }
}
