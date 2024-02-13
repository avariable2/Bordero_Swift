//
//  SIgnatureFormView.swift
//  Bordero
//
//  Created by Grande Variable on 13/02/2024.
//

import SwiftUI
import PencilKit

struct SignatureFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var drawnImage: UIImage?
    let canvasView = PKCanvasView()

    var body: some View {
        DrawingView(image: $drawnImage, canvasView: canvasView)
            .navigationTitle("Signature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        captureImage()
                        dismiss()
                    } label: {
                        Text("Sauvegarder")
                    }
                }
            }
      }
    
    func captureImage() {
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        drawnImage = image
    }
}

struct DrawingView : UIViewRepresentable {
    typealias UIViewType = PKCanvasView
    
    @Binding var image: UIImage?
    
    let canvasView : PKCanvasView
    let toolPicker = PKToolPicker()
    
    func makeUIView(context: Context) -> PKCanvasView {
        
        canvasView.drawingPolicy = .anyInput
        
        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        
        canvasView.becomeFirstResponder()
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator : NSObject {
        var parent : DrawingView
        
        init(_ parent : DrawingView) {
            self.parent = parent
        }
    }
}

#Preview {
    SignatureFormView()
}
