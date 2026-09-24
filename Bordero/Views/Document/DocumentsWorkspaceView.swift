import CoreData
import SwiftUI

struct DocumentsWorkspaceView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Document.dateEmission_, ascending: false)
        ]
    )
    private var documents: FetchedResults<Document>

    @State private var selectedDocumentID: NSManagedObjectID?
    @State private var isCreatingDocument = false

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                NavigationSplitView {
                    ListDocument(
                        selectedDocumentID: $selectedDocumentID,
                        onCreateDocument: createDocument
                    )
                } detail: {
                    NavigationStack {
                        Group {
                            if let document = selectedDocument {
                                DocumentDetailView(document: document)
                            } else {
                                ContentUnavailableView(
                                    "Sélectionnez un document",
                                    systemImage: "doc.text"
                                )
                            }
                        }
                        .navigationDestination(isPresented: $isCreatingDocument) {
                            DocumentFormView()
                        }
                    }
                    .background(Color(.systemGroupedBackground))
                }
                .navigationSplitViewStyle(.balanced)
            } else {
                NavigationStack {
                    ListDocument(onCreateDocument: createDocument)
                        .navigationDestination(isPresented: $isCreatingDocument) {
                            DocumentFormView()
                        }
                }
            }
        }
        .onAppear(perform: ensureSelection)
        .onChange(of: documents.map(\.objectID)) {
            ensureSelection()
        }
    }

    private var selectedDocument: Document? {
        documents.first { $0.objectID == selectedDocumentID }
    }

    private func ensureSelection() {
        if selectedDocument == nil {
            selectedDocumentID = documents.first?.objectID
        }
    }

    private func createDocument() {
        if UIDevice.current.userInterfaceIdiom == .pad && supportsMultipleWindows {
            openWindow(id: "invoice-creation", value: UUID())
        } else {
            isCreatingDocument = true
        }
    }
}

#Preview {
    DocumentsWorkspaceView()
        .environment(\.managedObjectContext, PreviewDataController.invoices.context)
}
