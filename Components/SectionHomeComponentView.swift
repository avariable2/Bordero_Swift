//
//  SectionHomeComponentView.swift
//  Bordero
//
//  Created by Grande Variable on 24/02/2024.
//

import SwiftUI

struct SectionHomeComponentView<Content : View>: View {
    
    var title : String
    @ViewBuilder var content : Content
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .bold()
            
            content
                
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
}

//#Preview {
//    SectionHomeComponentView<<#Content: View#>>(title: <#String#>, content: <#View#>)
//}
