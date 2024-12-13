//
//  FileSelectionView.swift
//  RecipeBook
//
//  Created by Антон Николаев on 13/12/2024.
//


import SwiftUI

struct FileSelectionView: View {
    @Binding var recipesFilePath: String
    @Binding var dishTypesFilePath: String
    @Environment(\.dismiss) private var dismiss

    @State private var showRecipesPicker = false
    @State private var showDishTypesPicker = false

    var onImport: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Файл рецептов")) {
                    Button(action: { showRecipesPicker = true }) {
                        HStack {
                            Text("Выбрать файл")
                            Spacer()
                            if !recipesFilePath.isEmpty {
                                Text("✓").foregroundColor(.green)
                            }
                        }
                    }
                    .sheet(isPresented: $showRecipesPicker) {
                        DocumentPicker(
                            documentTypes: [.json],
                            onFileSelected: { url in
                                recipesFilePath = url.path
                                showRecipesPicker = false
                            }
                        )
                    }
                }

                Section(header: Text("Файл типов блюд")) {
                    Button(action: { showDishTypesPicker = true }) {
                        HStack {
                            Text("Выбрать файл")
                            Spacer()
                            if !dishTypesFilePath.isEmpty {
                                Text("✓").foregroundColor(.green)
                            }
                        }
                    }
                    .sheet(isPresented: $showDishTypesPicker) {
                        DocumentPicker(
                            documentTypes: [.json],
                            onFileSelected: { url in
                                dishTypesFilePath = url.path
                                showDishTypesPicker = false
                            }
                        )
                    }
                }
            }
            .navigationTitle("Выбор файлов")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Импортировать") {
                        onImport()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}
