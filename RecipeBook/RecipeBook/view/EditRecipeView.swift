import SwiftUI
import SwiftData

struct EditRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var newName: String = ""
    @State private var newDescription: String = ""
    @State private var newIngredients: [String] = []
    @State private var newType: String = ""
    @State private var newImage: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var ingredientToAdd: String = ""
    
    // Динамический запрос существующих типов блюд
    @Query(sort: \DishType.name, order: .forward) private var dishTypes: [DishType]
    @State private var dishTypeNames: [String] = [] // Массив имён типов
    
    // Состояние для отображения предупреждений
        @State private var showAlert = false
    
    var body: some View {
//        NavigationView {
            Form {
                Section(header: Text("Информация о рецепте")) {
                    TextField("Название", text: $newName)
                    
                    TextEditor(text: $newDescription)
                        .frame(height: 100)
                    
                    Button(action: { showImagePicker.toggle() }) {
                        Text(newImage == nil ? "Выбрать изображение" : "Изменить изображение")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    if let imageData = newImage?.pngData(), let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                }
                
                Section(header: Text("Ингредиенты")) {
                  List {
                      ForEach(newIngredients, id: \.self) { ingredient in
                          HStack {
                              Image(systemName: "leaf.arrow.circlepath")
                                  .foregroundColor(.green)
                              Text(ingredient)
                                  .padding(.leading, 10)
                              Spacer()
                              Button(action: {
                                  newIngredients.removeAll(where: { $0 == ingredient })
                              }) {
                                  Image(systemName: "xmark.circle.fill")
                                      .foregroundColor(.red)
                              }
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
                    Picker("Тип", selection: $newType) {
                        ForEach(dishTypeNames, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                }
                
                Button(action: saveNewRecipe) {
                    Text("Сохранить Рецепт")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .alert("Название и описание должны быть заполнены", isPresented: $showAlert) {Button("OK") { }
                                    }
            }
            
//        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $newImage, showImagePicker: $showImagePicker)
        }
        .onAppear {
            // Заполнение массива имён типов блюд при появлении представления
            dishTypeNames = dishTypes.map { $0.name }
        }
    }
    
    private func addIngredient() {
           if !ingredientToAdd.isEmpty {
               newIngredients.append(ingredientToAdd)
               ingredientToAdd = ""  // Очистка поля после добавления
           }
       }
    
    private func saveNewRecipe() {
        showAlert = false
           guard !newName.isEmpty && !newDescription.isEmpty else {
               // Обработка ошибок: название и описание должны быть заполнены
               showAlert = true
               return
           }
        
        let newRecipe = Recipe(
            name: newName,
            recipeDescription: newDescription,
            ingredients: newIngredients,
            type: newType,
            image: newImage?.pngData()
        )
        
        modelContext.insert(newRecipe)
        do {
            try modelContext.save()
            dismiss() // Закрыть текущий экран после успешного сохранения
        } catch {
            print("Не удалось сохранить рецепт: \(error)")
        }
    }
}

struct EditRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        EditRecipeView()
    }
}

