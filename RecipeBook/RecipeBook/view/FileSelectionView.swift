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

    var onImport: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Файл рецептов")) {
                    TextField("Путь к файлу", text: $recipesFilePath)
                        .textInputAutocapitalization(.none)
                }
                Section(header: Text("Файл типов блюд")) {
                    TextField("Путь к файлу", text: $dishTypesFilePath)
                        .textInputAutocapitalization(.none)
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