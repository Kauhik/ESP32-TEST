//
//  Item.swift
//  ESP32 TEST
//
//  Created by Kaushik Manian on 5/3/25.
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
