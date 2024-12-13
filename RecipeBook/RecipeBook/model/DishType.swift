import Foundation
import SwiftData

@Model
final class DishType: Encodable, Decodable {
    var name: String
    var image: Data?
    @Attribute(.unique) var id: UUID = UUID()
    
    init(name: String, image: Data?) {
        self.name = name
        self.image = image
    }
    
    // Реализация метода encode(to:)
    enum CodingKeys: CodingKey {
        case name, image, id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(id, forKey: .id)
        
        // Обработка опционального изображения
        if let image = image {
            try container.encode(image, forKey: .image)
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        id = try container.decode(UUID.self, forKey: .id)
        
        // Обработка опционального изображения
        image = try? container.decode(Data.self, forKey: .image)
    }
}
