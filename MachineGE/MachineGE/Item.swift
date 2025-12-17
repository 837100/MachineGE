//
//  Item.swift
//  MachineGE
//
//  Created by sg on 12/17/25.
//

import Foundation
import SwiftData

// MARK: - 기존 Item 모델 (SwiftData 호환성 유지)
@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
