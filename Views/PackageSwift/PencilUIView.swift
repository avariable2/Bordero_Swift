//
//  PencilUIView.swift
//  Bordero
//
//  Created by Grande Variable on 21/03/2024.
//

import PencilKit
import SwiftUI

struct DrawingView : UIViewRepresentable {
    typealias UIViewType = PKCanvasView
    
    @Binding var image: UIImage?
    
    let canvasView = PKCanvasView()
//    let toolPicker = PKToolPicker()
    
    func makeUIView(context: Context) -> PKCanvasView {
        
        canvasView.drawingPolicy = .anyInput
        
//        toolPicker.setVisible(true, forFirstResponder: canvasView)
//        toolPicker.addObserver(canvasView)
        
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
