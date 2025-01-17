//
//  Item.swift
//  SwiftDataToDo
//
//  Created by Noel Mac on 1/17/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var title: String
    var timestamp: Date
    var isCompleted: Bool
    
    init(title: String = "", timestamp: Date = .now, isCompleted: Bool = false) {
        self.title = title
        self.timestamp = timestamp
        self.isCompleted = isCompleted
    }
}
