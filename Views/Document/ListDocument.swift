//
//  ListDocument.swift
//  Bordero
//
//  Created by Grande Variable on 21/04/2024.
//

import SwiftUI

struct ListDocument: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [
        
    ], predicate: NSPredicate(
        format: "version <= %d",
        argumentArray: [DocumentFormView.getVersion()]
    ))  var documents: FetchedResults<Document>
    
    var body: some View {
        VStack {
            if documents.isEmpty {
                ContentUnavailableView(
                    "Aucun document",
                    systemImage: "folder.badge.questionmark",
                    description: Text("Les documents créer apparaitront ici.").foregroundStyle(.secondary))
            } else {
                List {
                    ForEach(documents) { document in
                        let nomFichier = "\(document.snapshotClient.firstname) \(document.snapshotClient.lastname) \(document.estDeTypeFacture ? "Facture" : "Devis")"
                        RowDocumentView(text: nomFichier)
                    }
//                    .onDelete(perform: delete)
                }
            }
        }
        .navigationTitle("Documents")
    }
    
//    func delete(at offsets: IndexSet) {
//        for index in offsets {
//            let doc = documents[index]
//            moc.delete(doc)
//        }
//        
//        do {
//            try moc.save()
//            print("Success")
//        } catch let err {
//            print(err.localizedDescription)
//        }
//    }
}

struct RowDocumentView :View {
    let text : String
    
    var body: some View {
        Label {
            Text(text)
        } icon: {
            ColoredIconView(imageName: "doc", foregroundColor: .white, backgroundColor: .blue)
        }
        
    }
}

struct ColoredIconView: View {

    let imageName: String
    let foregroundColor: Color
    let backgroundColor: Color
    @State private var frameSize: CGSize = CGSize(width: 30, height: 30)
    @State private var cornerRadius: CGFloat = 5
    
    var body: some View {
        Image(systemName: imageName)
            .overlay(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: SFSymbolKey.self, value: max(proxy.size.width, proxy.size.height))
                }
            )
            
            .onPreferenceChange(SFSymbolKey.self) {
                let size = $0 * 1.05
                frameSize = CGSize(width:size, height: size)
                cornerRadius = $0 / 6.4
            }
            .frame(width: frameSize.width, height: frameSize.height)
            .foregroundColor(foregroundColor)
            .padding(1)
            .background(
//                RoundedRectangle(cornerRadius: cornerRadius)
                Circle()
                    .fill(backgroundColor)
            )
    }
}

fileprivate struct SFSymbolKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

#Preview {
    ListDocument()
}
