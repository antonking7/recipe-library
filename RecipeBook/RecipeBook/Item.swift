//
//  Item.swift
//  RecipeBook
//
//  Created by Антон Николаев on 04.12.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
