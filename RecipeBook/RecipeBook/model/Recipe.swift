import Foundation
import SwiftData

@Model
final class Recipe {
    var name: String
    var recipeDescription: String
    var ingredients: [String]?
    var type: String
    var id: UUID = UUID()
    var image: Data?
    
    init(name: String, recipeDescription: String, ingredients: [String]?, type: String, image: Data?) {
        self.name = name
        self.recipeDescription = recipeDescription
        self.ingredients = ingredients
        self.type = type
        self.image = image
    }
}
