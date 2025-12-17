//
//  EquipmentModels.swift
//  MachineGE
//
//  Created by sg on 12/17/25.
//

import Foundation

// MARK: - JSON 데이터 구조

/// 전체 장비 데이터 루트
struct EquipmentDataRoot: Codable {
    let brands: [Brand]
    let equipment: [EquipmentItem]
    let muscleGroups: [MuscleGroupInfo]
    let movementPatterns: [MovementPatternInfo]
}

/// 브랜드 정보
struct Brand: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let nameEn: String
    let country: String
    let description: String
    
    var origin: EquipmentOrigin {
        country == "domestic" ? .domestic : .international
    }
}

/// 장비 아이템
struct EquipmentItem: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let brandId: String
    let muscleGroup: String
    let movementPattern: String
    let description: String
    let targetMuscles: [String]
    let tips: String
}

/// 근육 그룹 정보
struct MuscleGroupInfo: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
}

/// 운동 궤적 정보
struct MovementPatternInfo: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
}

// MARK: - 뷰에서 사용할 통합 모델

/// 장비와 브랜드 정보가 결합된 뷰 모델
struct EquipmentViewModel: Identifiable, Hashable {
    let id: String
    let name: String
    let brand: Brand
    let muscleGroup: MuscleGroupInfo
    let movementPattern: MovementPatternInfo
    let description: String
    let targetMuscles: [String]
    let tips: String
    
    var origin: EquipmentOrigin {
        brand.origin
    }
}
