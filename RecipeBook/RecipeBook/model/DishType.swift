//
//  DishType.swift
//  RecipeBook
//
//  Created by Антон Николаев on 05.12.2024.
//


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
