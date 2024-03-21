//
//  SIgnatureFormView.swift
//  Bordero
//
//  Created by Grande Variable on 13/02/2024.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct SignatureFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var drawnImage: UIImage?
    
    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedImage: Image?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Text("Selectionner une image")
                    }
                    .onChange(of: pickerItem) {
                        Task {
                            selectedImage = try await pickerItem?.loadTransferable(type: Image.self)
                        }
                    }
                    
                    selectedImage?
                        .resizable()
                        .scaledToFit()
                }
                .listRowSeparator(.hidden)
                
                Section {
                    NavigationLink {
                        DrawingView(image: $drawnImage)
                    } label: {
                        RowIconColor(text: "Dessiner la signature", systemName: "square.and.pencil.circle.fill", color: .green)
                    }

                }
            }
            .navigationTitle("Signature")
        }
    }
}

#Preview {
    SignatureFormView()
}
