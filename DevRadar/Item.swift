//
//  Item.swift
//  DevRadar
//
//  Created by Jude Otine on 25/12/2025.
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
