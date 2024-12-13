import SwiftUI
import SwiftData

struct DishTypesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DishType.name, order: .forward) private var dishTypes: [DishType]
    
    @State private var isAddingNewDishType: Bool = false
    @State private var showSearchView: Bool = false
    @State private var isFileSelectionViewPresented: Bool = false
    @State private var recipesFilePath: String = ""
    @State private var dishTypesFilePath: String = ""
    @State private var showClearDataAlert: Bool = false
    @State private var shouldClearData: Bool = false



    var body: some View {
        List {
            ForEach(dishTypes) { dishType in
                NavigationLink(destination: ContentView(selectedDishType: dishType.name)) {
                    HStack {
                        if let imageData = dishType.image, let image = UIImage(data: imageData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                        Text(dishType.name)
                        Spacer()
                    }
                }
            }
            .onDelete(perform: deleteDishType)
        }
        .navigationTitle("Типы Блюд")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                Button(action: { isAddingNewDishType.toggle() }) {
                    Label("Добавить Тип", systemImage: "plus")
                }
            }
            ToolbarItem {
                Button(action: { showSearchView.toggle() }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.blue)
                }
            }
            ToolbarItem {
                Button(action: exportData) {
                    Label("Экспортировать", systemImage: "square.and.arrow-up")
                }
            }
            ToolbarItem {
                Button(action: { isFileSelectionViewPresented = true }) {
                    Label("Импортировать", systemImage: "square.and.arrow-down")
                }
            }
        }
        .sheet(isPresented: $isAddingNewDishType) {
            AddDishTypeView(isPresented: $isAddingNewDishType)
                .navigationTitle("Добавление нового типа блюда")
        }
        .sheet(isPresented: $showSearchView) {
            SearchRecipesView()
        }
        .sheet(isPresented: $isFileSelectionViewPresented) {
            FileSelectionView(
                recipesFilePath: $recipesFilePath,
                dishTypesFilePath: $dishTypesFilePath,
                onImport: {
                    print("Вызывается onImport из FileSelectionView")
                    importData()
                }
            )
        }
        .alert("Удалить старые данные?", isPresented: $showClearDataAlert) {
            Button("Да", role: .destructive) {
                shouldClearData = true
                importData()
            }
            Button("Нет", role: .cancel) {
                shouldClearData = false
                importData()
            }
        } message: {
            Text("Вы хотите удалить старые данные перед импортом?")
        }
    }

    private func deleteDishType(_ offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let dishType = dishTypes[index]
                modelContext.delete(dishType)
            }
        }
    }

    // Функция для экспорта данных
    private func exportData() {
        let encoder = JSONEncoder()
        
        guard let recipesJSONData = try? encoder.encode(recipes) else {
            print("Не удалось сериализовать данные рецептов.")
            return
        }
        
        guard let dishTypesJSONData = try? encoder.encode(dishTypes) else {
            print("Не удалось сериализовать данные типов блюд.")
            return
        }

        // Создаем временные файлы для записи данных
        let tempDirectoryURL = FileManager.default.temporaryDirectory

        let recipesFileURL = tempDirectoryURL.appendingPathComponent("recipes.json")
        let dishTypesFileURL = tempDirectoryURL.appendingPathComponent("dishTypes.json")

        do {
            try recipesJSONData.write(to: recipesFileURL)
            try dishTypesJSONData.write(to: dishTypesFileURL)

            // Запускаем системный диалог сохранения файлов
            shareFiles(fileUrls: [recipesFileURL, dishTypesFileURL])
        } catch {
            print("Не удалось записать данные в файлы: \(error)")
        }
    }
    
    private func clearData<T: PersistentModel>(ofType type: T.Type) {
        do {
            // Создаем дескриптор для выборки всех объектов типа T
            let fetchDescriptor = FetchDescriptor<T>()
            
            // Получаем все объекты
            let objects = try modelContext.fetch(fetchDescriptor)
            
            // Удаляем каждый объект
            for object in objects {
                modelContext.delete(object)
            }
            
            // Сохраняем изменения
            try modelContext.save()
            print("Данные типа \(T.self) успешно удалены.")
        } catch {
            print("Ошибка при удалении данных типа \(T.self): \(error)")
        }
    }
    
    private func importData() {
        let decoder = JSONDecoder()

        do {
            // Если выбран вариант "удалить данные", сначала очищаем
            if shouldClearData {
                clearData(ofType: Recipe.self)
                clearData(ofType: DishType.self)
                print("Старые данные удалены.")
            }

            // Импорт рецептов
            if !recipesFilePath.isEmpty,
               let recipesData = FileManager.default.contents(atPath: recipesFilePath) {
                print("Файл рецептов найден")
                let decodedRecipes = try decoder.decode([Recipe].self, from: recipesData)
                decodedRecipes.forEach { recipe in
                    modelContext.insert(recipe)
                }
                print("Рецепты импортированы.")
            } else {
                print("Файл рецептов не найден или путь пуст")
            }

            // Импорт типов блюд
            if !dishTypesFilePath.isEmpty,
               let dishTypesData = FileManager.default.contents(atPath: dishTypesFilePath) {
                print("Файл типов блюд найден")
                let decodedDishTypes = try decoder.decode([DishType].self, from: dishTypesData)
                decodedDishTypes.forEach { dishType in
                    modelContext.insert(dishType)
                }
                print("Типы блюд импортированы.")
            } else {
                print("Файл типов блюд не найден или путь пуст")
            }

            // Сохраняем изменения
            try modelContext.save()

        } catch {
            print("Ошибка импорта данных: \(error)")
        }
    }

    private func shareFiles(fileUrls: [URL]) {
        let activityViewController = UIActivityViewController(activityItems: fileUrls, applicationActivities: nil)
        
        // Получаем корневой контроллер представления
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }

    @Query(sort: \Recipe.name, order: .forward) private var recipes: [Recipe]
}

struct DishTypesView_Previews: PreviewProvider {
    static var previews: some View {
        DishTypesView()
    }
}
