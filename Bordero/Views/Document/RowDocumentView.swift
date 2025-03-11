//
//  RowDocumentView.swift
//  Bordero
//
//  Created by Grande Variable on 11/03/2025.
//

import SwiftUI

struct RowDocumentView :View {
    
    var horizontalSizeClass : UserInterfaceSizeClass?
    @ObservedObject var document : FetchedResults<Document>.Element
    
    var isLate : Bool {
        document.dateEcheance <= Date() && document.status == .send
    }
    
    var body: some View {
        NavigationLink {
            DocumentDetailView(document: document)
        } label : {
            HStack {
                VStack(alignment: .trailing) {
                    Text(document.dateEmission.formatted(.dateTime.day()))
                    + Text("\n")
                    + Text(document.dateEmission.formatted(.dateTime.month()))
                    
                }
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(4)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(document.getNameOfDocument())
                        .font(.callout)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 4) {
                        IconStatusDocument(status: document.determineStatut())
                        
                        Divider()
                            .frame(height: 10)
                        
                        Image(systemName: "stopwatch")
                        
                        Text(document.dateEcheance.formatted(.dateTime.day().month().year()))
                            .foregroundStyle(isLate ? .red : .secondary)
                        
                        Divider()
                            .frame(height: 10)
                        
                        Text(document.totalTTC, format: .currency(code: "EUR"))
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fontWeight(.medium)
                    
                }
                .padding(.leading, 4)
            }
        }
    }
}

#Preview {
    NavigationStack {
        List{
            RowDocumentView(horizontalSizeClass: .regular, document: Document.example)
            RowDocumentView(horizontalSizeClass: .regular, document: Document.example)
        }
        
//        ListDocument()
    }
}
