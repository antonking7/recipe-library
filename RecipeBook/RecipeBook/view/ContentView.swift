import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.name, order: .forward) private var recipes: [Recipe]
    
    let selectedDishType: String
    
    // Добавляем состояние для управления отображением EditRecipeView
    @State private var isShowingEditRecipeView: Bool = false

    var body: some View {
            List {
                ForEach(recipes.filter { $0.type == selectedDishType }) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe)
                    } label: {
                        HStack {
                            if let imageData = recipe.image, let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                            }
                            Text(recipe.name)
                        }
                    }
                }
                .onDelete(perform: deleteRecipes)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { isShowingEditRecipeView.toggle() }) {
                        Label("Добавить Рецепт", systemImage: "plus")
                    }
                }
            }
        // Добавляем sheet для отображения EditRecipeView
        .sheet(isPresented: $isShowingEditRecipeView) {
            EditRecipeView()
                .navigationTitle("Редактирование рецепта")
        }
    }
    
    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(recipes[index])
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(selectedDishType: "Основные блюда")
    }
}
