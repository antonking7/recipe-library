import SwiftUI
import SwiftData

struct EditRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var newName: String = ""
    @State private var newDescription: String = ""
    @State private var newIngredients: [String] = []
    @State private var newType: String = "Salad"
    @State private var newImage: UIImage?
    @State private var showImagePicker: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 20) {
                if let image = newImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                } else {
                    Button(action: { showImagePicker = true }) {
                        Label("Select Image", systemImage: "photo")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                TextField("Name", text: $newName)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                TextField("Description", text: $newDescription, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(nil) // Разрешает несколько строк
                    .padding()
                
                VStack(alignment: .leading) {
                    Text("Ingredients")
                        .font(.headline)
                    
                    ForEach(newIngredients.indices, id: \.self) { index in
                        HStack {
                            TextField("Ingredient", text: $newIngredients[index])
                                .textFieldStyle(.roundedBorder)
                            
                            Button(action: {
                                newIngredients.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Button(action: addIngredient) {
                        Label("Add Ingredient", systemImage: "plus")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                Picker("Type", selection: $newType) {
                    Text("Salad").tag("Salad")
                    Text("Main Course").tag("Main Course")
                    Text("Dessert").tag("Dessert")
                }
                .pickerStyle(.segmented)
                .padding()
                
                Button(action: saveNewRecipe) {
                    Text("Save Recipe")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
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
            print("Failed to save recipe: \(error)")
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
