import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.name, order: .forward) private var recipes: [Recipe]
    
    let selectedDishType: String
    
    var body: some View {
        NavigationSplitView {
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
                    NavigationLink(destination: EditRecipeView()) {
                        Label("Добавить Рецепт", systemImage: "plus")
                    }
                    
                }
            }
        } detail: {
            Text("Выберите рецепт")
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
