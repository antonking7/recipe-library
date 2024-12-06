import SwiftUI
import SwiftData

struct EditRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode
    
    @Query(sort: \DishType.name, order: .forward) private var dishTypes: [DishType]
    
    @State private var newName: String = ""
    @State private var newDescription: String = ""
    @State private var newIngredients: [String] = []
    @State private var newTypeId: UUID? // Используем UUID для выбора типа блюда
    @State private var newImage: UIImage?
    @State private var showImagePicker: Bool = false
    
    @State private var showAlert = false
    
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
                            .padding(.horizontal)
                        
                        if newIngredients.isEmpty {
                            Button(action: addIngredient) {
                                Label("Добавить Ингредиент", systemImage: "plus")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding()
                            .frame(maxWidth: geometry.size.width - 40, alignment: .center) // Выравнивание по центру с отступом
                        } else {
                            ForEach(newIngredients.indices, id: \.self) { index in
                                HStack {
                                    TextField("Ингредиент", text: $newIngredients[index])
                                        .padding()
                                        .textFieldStyle(.roundedBorder)
                                    
                                    Button(action: {
                                        newIngredients.remove(at: index)
                                    }) {
                                        Image(systemName: "minus.circle")
                                            .foregroundColor(.red)
                                    }
                                    .padding()
                                }
                                .padding(.horizontal)
                            }
                            
                            Button(action: addIngredient) {
                                Label("Добавить Ингредиент", systemImage: "plus")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding()
                        }
                    }
                    
                    Picker(selection: $newTypeId, label: Text("Тип блюда")) {
                        ForEach(dishTypes) { dishType in
                            Text(dishType.name).tag(dishType.id as UUID?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                    
                    Button(action: saveRecipe) {
                        Text("Сохранить Рецепт")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: geometry.size.width - 40, alignment: .center)
                    .disabled(newName.isEmpty || newDescription.isEmpty || newTypeId == nil)
                    
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Отмена")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: geometry.size.width - 40, alignment: .center)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $newImage, showImagePicker: $showImagePicker)
        }
    }
    
    private func addIngredient() {
        newIngredients.append("")
    }
    
    private func saveRecipe() {
        guard !newName.isEmpty, !newDescription.isEmpty, let dishTypeId = newTypeId else {
            showAlert = true
            return
        }
        
        // Найти объект DishType по UUID
        if let selectedDishType = dishTypes.first(where: { $0.id == dishTypeId }) {
            let newRecipe = Recipe(
                name: newName,
                recipeDescription: newDescription,
                ingredients: newIngredients,
                type: selectedDishType.name, // Или используйте другой идентификатор
                image: newImage?.pngData()
            )
            
            modelContext.insert(newRecipe)
            do {
                try modelContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("Не удалось сохранить рецепт: \(error)")
            }
        }
    }
}
