//
//  EditRecipeDetailView.swift
//  RecipeBook
//
//  Created by Антон Николаев on 10/12/2024.
//

import SwiftUI
import SwiftData

struct EditRecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Состояние для хранения данных рецепта
    @State private var name: String
    @State private var description: String
    @State private var ingredients: [String]
    @State private var type: String
    @State private var image: UIImage?
    @State private var id: UUID
    
    @State private var showImagePicker: Bool = false
    @State private var ingredientToAdd: String = ""
    
    // Динамический запрос существующих типов блюд
    @Query(sort: \DishType.name, order: .forward) private var dishTypes: [DishType]
    @State private var dishTypeNames: [String] = [] // Массив имён типов
    
    // Состояние для отображения предупреждений
    @State private var showAlert = false
    @State private var editingIngredientIndex: Int? = nil // Индекс ингредиента для редактирования
    
    init(recipe: Recipe) {
        _name = State(initialValue: recipe.name)
        _description = State(initialValue: recipe.recipeDescription)
        _ingredients = State(initialValue: recipe.ingredients ?? [])
        _type = State(initialValue: recipe.type)
        if let imageData = recipe.image, let uiImage = UIImage(data: imageData) {
            _image = State(initialValue: uiImage)
        }
        _id = State(initialValue: recipe.id)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Информация о рецепте")) {
                TextField("Название", text: $name)
                
                TextEditor(text: $description)
                    .frame(height: 200)
                
                Button(action: { showImagePicker.toggle() }) {
                    Text(image == nil ? "Выбрать изображение" : "Изменить изображение")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                if let imageData = image?.pngData(), let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
            }
            
            Section(header: Text("Ингредиенты")) {
                List {
                    ForEach(Array(ingredients.enumerated()), id: \.offset) { index, ingredient in
                        HStack {
                            Image(systemName: "leaf.arrow.circlepath")
                                .foregroundColor(.green)
                            
                            if editingIngredientIndex == index {
                                TextField("Редактирование ингредиента", text: Binding(get: { ingredient }, set: { ingredients[index] = $0 }))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                Text(ingredient)
                                    .padding(.leading, 10)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                HStack {
                    TextField("Новый ингредиент", text: $ingredientToAdd)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: addIngredient) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Section(header: Text("Тип блюда")) {
                Picker("Тип", selection: $type) {
                    ForEach(dishTypeNames, id: \.self) { name in
                        Text(name).tag(name)
                    }
                }
            }
            
            Button(action: saveRecipe) {
                Text("Сохранить Рецепт")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .alert("Название и описание должны быть заполнены", isPresented: $showAlert) { Button("OK") {}}
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $image, showImagePicker: $showImagePicker)
        }
        .onAppear {
            // Заполнение массива имён типов блюд при появлении представления
            dishTypeNames = dishTypes.map { $0.name }
            // Предзаполнение типа блюда первым элементом из списка, если список не пустой
               if let firstTypeName = dishTypeNames.first {
                   let newType = self.type
               }
        }
        .onDisappear {
            editingIngredientIndex = nil // Сброс индекса редактирования при закрытии представления
        }
    }
    
    private func addIngredient() {
        if !ingredientToAdd.isEmpty {
            ingredients.append(ingredientToAdd)
            ingredientToAdd = ""  // Очистка поля после добавления
        }
    }
    
    private func saveRecipe() {
        showAlert = false
        guard !name.isEmpty && !description.isEmpty else {
            // Обработка ошибок: название и описание должны быть заполнены
            showAlert = true
            return
        }
        
        let userId = self.id
        let predicate = #Predicate<Recipe> { $0.id == userId }
        let fetchDescriptor = FetchDescriptor(predicate: predicate)
        
        do {
            let recipes = try modelContext.fetch(fetchDescriptor)
            
            if let existingRecipe = recipes.first {
                // Обновляем существующий рецепт
                existingRecipe.name = name
                existingRecipe.recipeDescription = description
                existingRecipe.ingredients = ingredients
                existingRecipe.type = type
                existingRecipe.image = image?.pngData()
                
                try modelContext.save()
                dismiss() // Закрыть текущий экран после успешного сохранения
            } else {
                print("Рецепт не найден")
            }
        } catch {
            print("Не удалось сохранить рецепт: \(error)")
        }
    }
}
