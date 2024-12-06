import SwiftUI
import SwiftData

@main
struct RecipeBookApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Recipe.self,
            DishType.self, // Include the new model in the schema
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Не удалось создать ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                DishTypesView()
                    .navigationTitle("Типы Блюд")
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
