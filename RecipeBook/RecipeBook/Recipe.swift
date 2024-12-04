import Foundation
import SwiftData

@Model
final class Recipe {
    var name: String
    var recipeDesc: String
    var ingredients: [String]
    var type: String
    @Persistent(primaryKey: true) var id: UUID = UUID()
    var image: Data? // Изображение в формате Data
    
    init(name: String, recipeDesc: String, ingredients: [String], type: String, image: Data?) {
        self.name = name
        self.recipeDesc = recipeDesc
        self.ingredients = ingredients
        self.type = type
        self.image = image
    }
}
