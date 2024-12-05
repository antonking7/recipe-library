import Foundation
import SwiftData

@Model
final class DishType {
    var name: String
    var image: Data?
    var id: UUID = UUID()
    
    init(name: String, image: Data?) {
        self.name = name
        self.image = image
    }
}
