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
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: geometry.size.width - 40, alignment: .center)
                            
                        
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
                    .alert("названия и описание должны быть заполнены", isPresented: $showAlert) {
                        Button("OK") { }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $newImage, showImagePicker: $showImagePicker)
        }
    }
    
    private func addIngredient() {
        newIngredients.append("")
    }
    
    private func saveNewRecipe() {
        showAlert = false
        guard !newName.isEmpty && !newDescription.isEmpty else {
            // Обработка ошибок: названия и описание должны быть заполнены
            showAlert = true
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

  
