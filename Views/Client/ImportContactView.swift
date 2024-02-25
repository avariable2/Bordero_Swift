//
//  AddContact.swift
//  Bordero
//
//  Created by Grande Variable on 07/02/2024.
//

import SwiftUI
import Contacts
import ContactsUI

struct ContactPicker: UIViewControllerRepresentable {
    @Binding var selectedContact: CNContact?
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {
        // Pas besoin de mettre à jour le picker dans cet exemple
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ContactPicker
        
        init(_ parent: ContactPicker) {
            self.parent = parent
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            parent.selectedContact = contact
        }
    }
}

struct ImportContactView<Content : View>: View {
    @State private var showingContactPicker = false
    @Binding var selectedContact: CNContact?
    
    @ViewBuilder var content : Content
    
    var body: some View {
        Button {
            showingContactPicker = true
        } label: {
            content
        }
        .sheet(isPresented: $showingContactPicker, onDismiss: nil) {
            ContactPicker(selectedContact: $selectedContact)
        }
        .controlSize(.large)
    }
}

//#Preview {
//    AddContact(selectedContact: .constant(CNContact()))
//}
