//
//  Item.swift
//  MachineGE
//
//  Created by sg on 12/17/25.
//

import Foundation
import SwiftData

// MARK: - 장비 유형 (국내/해외)
enum EquipmentOrigin: String, CaseIterable, Codable {
    case domestic = "국내"
    case international = "해외"
}

// MARK: - 기존 Item 모델 (SwiftData 호환성 유지)
@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
