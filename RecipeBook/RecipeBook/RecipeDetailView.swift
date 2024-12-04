import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let imageData = recipe.image, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
            
            Text(recipe.name)
                .font(.largeTitle)
                .bold()
            
            Text(recipe.recipeDescription)
                .font(.body)
            
            VStack(alignment: .leading) {
                Text("Ingredients")
                    .font(.headline)
                
                ForEach((recipe.ingredients ?? []).indices, id: \.self) { index in
                    Text("- \(recipe.ingredients?[index] ?? "")")
                }
            }
            
            Text("Type: \(recipe.type)")
                .font(.headline)
            
        }
        .padding()
    }
}
