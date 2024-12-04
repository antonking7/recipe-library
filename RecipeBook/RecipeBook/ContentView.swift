import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.name, order: .forward) private var recipes: [Recipe]
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(recipes) { recipe in
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
                        Label("Edit Recipe", systemImage: "plus")
                    }
                    
                }
            }
        } detail: {
            Text("Select a recipe")
        }
    }
    
    private func addRecipe() {
        withAnimation {
            let newRecipe = Recipe(name: "", recipeDescription: "", ingredients: [], type: "", image: nil)
            modelContext.insert(newRecipe)
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

#Preview {
    ContentView()
        .modelContainer(for: Recipe.self, inMemory: true)
}
