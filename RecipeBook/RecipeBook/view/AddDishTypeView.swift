//
//  AddDishTypeView.swift
//  RecipeBook
//
//  Created by Антон Николаев on 06.12.2024.
//


import SwiftUI
import SwiftData

struct AddDishTypeView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    
    @State private var newName: String = ""
    @State private var newImage: UIImage?
    @State private var showImagePicker: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Название типа блюда", text: $newName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Button(action: { showImagePicker.toggle() }) {
                    Text(newImage == nil ? "Выбрать изображение" : "Изменить изображение")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                if let imageData = newImage?.pngData(), let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .padding(.horizontal)
                }
                
                Button(action: saveNewDishType) {
                    Text("Сохранить Тип")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .navigationTitle("Добавление нового типа блюда")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        isPresented = false
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $newImage, showImagePicker: $showImagePicker)
        }
    }

    private func saveNewDishType() {
        guard !newName.isEmpty else {
            return // Handle error if needed
        }
        
        let newDishType = DishType(
            name: newName,
            image: newImage?.pngData()
        )
        
        modelContext.insert(newDishType)
        do {
            try modelContext.save()
            isPresented = false
            newName = ""
            newImage = nil
        } catch {
            print("Не удалось сохранить тип блюда: \(error)")
        }
    }
}

struct AddDishTypeView_Previews: PreviewProvider {
    static var previews: some View {
        AddDishTypeView(isPresented: .constant(true))
    }
}
