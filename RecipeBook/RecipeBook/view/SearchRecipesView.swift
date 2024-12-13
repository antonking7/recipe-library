//
//  SearchRecipesView.swift
//  RecipeBook
//
//  Created by Антон Николаев on 08/12/2024.
//

import SwiftUI
import SwiftData

struct SearchRecipesView: View {
    @Environment(\.modelContext) private var modelContext
    
    // State to hold the search text
    @State private var searchText = ""
    @Query(sort: \Recipe.name, order: .forward) private var allRecipes: [Recipe]
    
    @FocusState private var isFocused: Bool
    
    // Filtered recipes based on the search text
    var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return allRecipes  // Return all recipes if the search text is empty
        } else {
            return allRecipes.filter { recipe in
                let nameMatch = recipe.name.localizedCaseInsensitiveContains(searchText)
                let descriptionMatch = recipe.recipeDescription.localizedCaseInsensitiveContains(searchText)
                let ingredientsMatch = recipe.ingredients?.joined(separator: " ").localizedCaseInsensitiveContains(searchText) ?? false
                let typeMatch = recipe.type.localizedCaseInsensitiveContains(searchText)
                
                return nameMatch || descriptionMatch || ingredientsMatch || typeMatch
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                TextField("Поиск рецептов", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .focused($isFocused)  // Set the focused state to this TextField
                    .onAppear {  // Automatically set focus when the view appears
                        isFocused = true
                    }
                
                // List of filtered recipes
                List(filteredRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        Text(recipe.name)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Поиск")
        }
    }
}

struct SearchRecipesView_Previews: PreviewProvider {
    static var previews: some View {
        SearchRecipesView()
    }
}
