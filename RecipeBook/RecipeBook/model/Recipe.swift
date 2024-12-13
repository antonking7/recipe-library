import Foundation
import SwiftData

@Model
final class Recipe: Encodable, Decodable {
    var name: String
    var recipeDescription: String
    var ingredients: [String]?
    var type: String
    @Attribute(.unique) var id: UUID = UUID()
    var image: Data?

    enum CodingKeys: CodingKey {
        case name, recipeDescription, ingredients, type, id, image
    }
    
    init(name: String, recipeDescription: String, ingredients: [String]?, type: String, image: Data?) {
        self.name = name
        self.recipeDescription = recipeDescription
        self.ingredients = ingredients
        self.type = type
        self.image = image
    }

    // Реализация метода encode(to:)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(recipeDescription, forKey: .recipeDescription)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encode(type, forKey: .type)
        try container.encode(id, forKey: .id)
        
        // Обработка опционального изображения
        if let image = image {
            try container.encode(image, forKey: .image)
        }
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        recipeDescription = try container.decode(String.self, forKey: .recipeDescription)
        ingredients = try? container.decode([String].self, forKey: .ingredients)
        type = try container.decode(String.self, forKey: .type)
        id = try container.decode(UUID.self, forKey: .id)

        // Обработка опционального изображения
        image = try? container.decode(Data.self, forKey: .image)
    }
}
