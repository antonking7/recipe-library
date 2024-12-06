import SwiftUI
import SwiftData


struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                if let imageData = recipe.image, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(15)
                        .shadow(radius: 8)
                }
                
                Text(recipe.name)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.primary)
                
                if !recipe.recipeDescription.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Описание рецепта")
                            .font(.headline)
                        
                        Text(recipe.recipeDescription)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(15)
                    .shadow(radius: 8)
                }
                
                if let ingredients = recipe.ingredients, !ingredients.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ингредиенты")
                            .font(.headline)
                        
                        ForEach(ingredients.indices, id: \.self) { index in
                            Text("- \(ingredients[index])")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(15)
                    .shadow(radius: 8)
                }
                
                if !recipe.type.isEmpty {
                    Text("Тип рецепта: \(recipe.type)")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            .padding()
        }
        .background(Color(uiColor: .systemBackground))
    }
}

