//
//  DocumentPicker.swift
//  RecipeBook
//
//  Created by Антон Николаев on 09/12/2024.
//


import SwiftUI

struct DocumentPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    
    var isExport: Bool
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentTypes = ["public.json"]
        let picker: UIDocumentPickerViewController
        
        if isExport {
            picker = UIDocumentPickerViewController(forExporting: [])
        } else {
            picker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .import)
        }
        
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No need to update anything here
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension DocumentPicker {
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            DocumentPicker.selectedFileURL?(url)
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            DocumentPicker.selectedFileURL?(nil)
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

extension DocumentPicker {
    static var selectedFileURL: ((URL?) -> Void)?
}
