import SwiftUI
import SwiftData

struct EditRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var newName: String = ""
    @State private var newDescription: String = ""
    @State private var newIngredients: [String] = []
    @State private var newType: String = "Салат"
    @State private var newImage: UIImage?
    @State private var showImagePicker: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let image = newImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    } else {
                        Button(action: { showImagePicker = true }) {
                            Label("Выбрать Изображение", systemImage: "photo")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .frame(maxWidth: geometry.size.width - 40, alignment: .center) // Выравнивание по центру с отступом
                    }
                    
                    TextField("Название", text: $newName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .autocapitalization(.words)
                    
                    TextField("Описание", text: $newDescription, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(nil) // Разрешает несколько строк
                        .padding(.horizontal)
                    
                    VStack(alignment: newIngredients.isEmpty ? .center : .leading) {
                        Text("Ингредиенты")
                            .font(.headline)
                        
                        if newIngredients.isEmpty {
                            Button(action: addIngredient) {
                                Label("Добавить Ингредиент", systemImage: "plus")
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .frame(maxWidth: geometry.size.width - 40, alignment: .center) // Выравнивание по центру с отступом
                        } else {
                            ForEach(newIngredients.indices, id: \.self) { index in
                                HStack {
                                    TextField("Ингредиент", text: $newIngredients[index])
                                        .textFieldStyle(.roundedBorder)
                                    
                                    Button(action: {
                                        newIngredients.remove(at: index)
                                    }) {
                                        Image(systemName: "minus.circle")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            Button(action: addIngredient) {
                                Label("Добавить Ингредиент", systemImage: "plus")
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .frame(maxWidth: geometry.size.width - 40, alignment: .center) // Выравнивание по центру с отступом
                        }
                    }
                    
                    Picker("Тип", selection: $newType) {
                        Text("Салат").tag("Салат")
                        Text("Основное Блюдо").tag("Основное Блюдо")
                        Text("Десерт").tag("Десерт")
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    Button(action: saveNewRecipe) {
                        Text("Сохранить Рецепт")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: geometry.size.width - 40, alignment: .center) // Выравнивание по центру с отступом
                }
                .padding()
            }
        }
        .onAppear {
            newIngredients.append("") // Добавляем пустой ингредиент при запуске
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $newImage, showImagePicker: $showImagePicker)
        }
    }
    
    private func addIngredient() {
        newIngredients.append("")
    }
    
    private func saveNewRecipe() {
        guard !newName.isEmpty && !newDescription.isEmpty else {
            // Обработка ошибок: названия и описание должны быть заполнены
            return
        }
        
        let newRecipe = Recipe(
            name: newName,
            recipeDescription: newDescription,
            ingredients: newIngredients.filter { !$0.isEmpty },
            type: newType,
            image: newImage?.pngData()
        )
        
        modelContext.insert(newRecipe)
        do {
            try modelContext.save()
            presentationMode.wrappedValue.dismiss() // Возвращаемся назад после сохранения
        } catch {
            print("Не удалось сохранить рецепт: \(error)")
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var showImagePicker: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            
            parent.showImagePicker = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.showImagePicker = false
        }
    }
    }
