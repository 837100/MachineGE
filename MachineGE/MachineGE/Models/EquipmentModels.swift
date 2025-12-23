//
//  EquipmentModels.swift
//  MachineGE
//
//  Created by sg on 12/17/25.
//

import Foundation

// MARK: - 장비 제조 국가
enum EquipmentOrigin: String, CaseIterable, Codable {
    case domestic = "국내"
    case international = "해외"
}

// MARK: - 운동 자세
enum Position: String, CaseIterable, Codable, Identifiable {
    case seated = "seated"
    case standing = "standing"
    case lying = "lying"
    case kneeling = "kneeling"
    case inclined = "inclined"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .seated: return "시티드"
        case .standing: return "스탠딩"
        case .lying: return "라잉"
        case .kneeling: return "닐링"
        case .inclined: return "인클라인"
        }
    }
    
    var description: String {
        switch self {
        case .seated: return "앉은 자세로 수행"
        case .standing: return "서서 수행"
        case .lying: return "누운 자세로 수행"
        case .kneeling: return "무릎을 꿇고 수행"
        case .inclined: return "기울어진 자세로 수행"
        }
    }
    
    var icon: String {
        switch self {
        case .seated: return "figure.seated.side"
        case .standing: return "figure.stand"
        case .lying: return "figure.roll"
        case .kneeling: return "figure.flexibility"
        case .inclined: return "figure.seated.side.air.upper"
        }
    }
}

// MARK: - 근육 부위
enum MuscleGroup: String, CaseIterable, Codable, Identifiable {
    case chest = "chest"
    case back = "back"
    case shoulder = "shoulder"
    case legs = "legs"
    case arms = "arms"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .chest: return "가슴"
        case .back: return "등"
        case .shoulder: return "어깨"
        case .legs: return "하체"
        case .arms: return "팔"
        }
    }
    
    var icon: String {
        switch self {
        case .chest: return "figure.arms.open"
        case .back: return "figure.walk"
        case .shoulder: return "figure.boxing"
        case .legs: return "figure.run"
        case .arms: return "figure.strengthtraining.traditional"
        }
    }
    
    var trajectories: [Trajectory] {
        switch self {
        case .chest: return ChestTrajectory.allCases.map { .chest($0) }
        case .back: return BackTrajectory.allCases.map { .back($0) }
        case .shoulder: return ShoulderTrajectory.allCases.map { .shoulder($0) }
        case .legs: return StanceWidth.allCases.map { .legs($0) }
        case .arms: return StanceWidth.allCases.map { .arms($0) }
        }
    }
    
    var movements: [Movement] {
        switch self {
        case .chest: return ChestMovement.allCases.map { .chest($0) }
        case .back: return BackMovement.allCases.map { .back($0) }
        case .shoulder: return ShoulderMovement.allCases.map { .shoulder($0) }
        case .legs: return LegMovement.allCases.map { .legs($0) }
        case .arms: return ArmMovement.allCases.map { .arms($0) }
        }
    }
}

// MARK: - 가슴 궤적
enum ChestTrajectory: String, CaseIterable, Codable {
    case incline, flat, decline
    
    var displayName: String {
        switch self {
        case .incline: return "인클라인"
        case .flat: return "플랫"
        case .decline: return "디클라인"
        }
    }
    
    var description: String {
        switch self {
        case .incline: return "상부 가슴 타겟"
        case .flat: return "중앙 가슴 타겟"
        case .decline: return "하부 가슴 타겟"
        }
    }
}

// MARK: - 가슴 동작
enum ChestMovement: String, CaseIterable, Codable {
    case press, fly
    var displayName: String { self == .press ? "프레스" : "플라이" }
}

// MARK: - 등 궤적
enum BackTrajectory: String, CaseIterable, Codable {
    case high_row, mid_row, low_row, front_pulldown, pulldown
    
    var displayName: String {
        switch self {
        case .high_row: return "하이 로우"
        case .mid_row: return "미드 로우"
        case .low_row: return "로우 로우"
        case .front_pulldown: return "프론트 풀다운"
        case .pulldown: return "풀다운"
        }
    }
    
    var description: String {
        switch self {
        case .high_row: return "높은 위치 로우"
        case .mid_row: return "기본 로우"
        case .low_row: return "낮은 위치 로우"
        case .front_pulldown: return "앞쪽 풀다운"
        case .pulldown: return "기본 풀다운"
        }
    }
}

// MARK: - 등 동작
enum BackMovement: String, CaseIterable, Codable {
    case pulldown, row
    var displayName: String { self == .pulldown ? "풀다운" : "로우" }
}

// MARK: - 어깨 궤적
enum ShoulderTrajectory: String, CaseIterable, Codable {
    case front, overhead, behind
    
    var displayName: String {
        switch self {
        case .front: return "프론트"
        case .overhead: return "오버헤드"
        case .behind: return "비하인드"
        }
    }
    
    var description: String {
        switch self {
        case .front: return "전면 삼각근"
        case .overhead: return "정수리 방향 프레스"
        case .behind: return "후면 삼각근"
        }
    }
}

// MARK: - 어깨 동작
enum ShoulderMovement: String, CaseIterable, Codable {
    case press, raise
    var displayName: String { self == .press ? "프레스" : "레이즈" }
}

// MARK: - 하체/팔 스탠스 너비
enum StanceWidth: String, CaseIterable, Codable {
    case narrow, standard, wide
    
    var displayName: String {
        switch self {
        case .narrow: return "내로우"
        case .standard: return "스탠다드"
        case .wide: return "와이드"
        }
    }
    
    var description: String {
        switch self {
        case .narrow: return "좁은 스탠스"
        case .standard: return "기본 스탠스"
        case .wide: return "넓은 스탠스"
        }
    }
}

// MARK: - 하체 동작
enum LegMovement: String, CaseIterable, Codable {
    case press, curl, `extension`
    var displayName: String {
        switch self {
        case .press: return "프레스"
        case .curl: return "컬"
        case .extension: return "익스텐션"
        }
    }
}

// MARK: - 팔 동작
enum ArmMovement: String, CaseIterable, Codable {
    case press, curl, `extension`
    var displayName: String {
        switch self {
        case .press: return "프레스"
        case .curl: return "컬"
        case .extension: return "익스텐션"
        }
    }
}

// MARK: - 통합 궤적 타입
enum Trajectory: Hashable, Identifiable {
    case chest(ChestTrajectory)
    case back(BackTrajectory)
    case shoulder(ShoulderTrajectory)
    case legs(StanceWidth)
    case arms(StanceWidth)
    
    var id: String { rawValue }
    
    var rawValue: String {
        switch self {
        case .chest(let t): return t.rawValue
        case .back(let t): return t.rawValue
        case .shoulder(let t): return t.rawValue
        case .legs(let t): return t.rawValue
        case .arms(let t): return t.rawValue
        }
    }
    
    var displayName: String {
        switch self {
        case .chest(let t): return t.displayName
        case .back(let t): return t.displayName
        case .shoulder(let t): return t.displayName
        case .legs(let t): return t.displayName
        case .arms(let t): return t.displayName
        }
    }
    
    var description: String {
        switch self {
        case .chest(let t): return t.description
        case .back(let t): return t.description
        case .shoulder(let t): return t.description
        case .legs(let t): return t.description
        case .arms(let t): return t.description
        }
    }
}

// MARK: - 통합 동작 타입
enum Movement: Hashable, Identifiable {
    case chest(ChestMovement)
    case back(BackMovement)
    case shoulder(ShoulderMovement)
    case legs(LegMovement)
    case arms(ArmMovement)
    
    var id: String { rawValue }
    
    var rawValue: String {
        switch self {
        case .chest(let m): return m.rawValue
        case .back(let m): return m.rawValue
        case .shoulder(let m): return m.rawValue
        case .legs(let m): return m.rawValue
        case .arms(let m): return m.rawValue
        }
    }
    
    var displayName: String {
        switch self {
        case .chest(let m): return m.displayName
        case .back(let m): return m.displayName
        case .shoulder(let m): return m.displayName
        case .legs(let m): return m.displayName
        case .arms(let m): return m.displayName
        }
    }
}

// MARK: - JSON 데이터 구조

struct Brand: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let nameEn: String
    let country: String
    let description: String
    let website: String?
    let imageUrl: String?

    var origin: EquipmentOrigin {
        country == "domestic" ? .domestic : .international
    }
}

struct BrandDataRoot: Codable {
    let brand: Brand
    let equipment: [EquipmentItem]
}

struct EquipmentItem: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let muscleGroup: String
    let trajectory: String
    let movement: String
    let position: String
    let description: String
    let targetMuscles: [String]
    let tips: String
    let url: String?
}

// MARK: - 뷰 모델

struct EquipmentViewModel: Identifiable, Hashable {
    let id: String
    let name: String
    let brand: Brand
    let muscleGroup: MuscleGroup
    let trajectory: Trajectory
    let movement: Movement
    let position: Position
    let description: String
    let targetMuscles: [String]
    let tips: String
    let url: String?
    
    var origin: EquipmentOrigin { brand.origin }
}
