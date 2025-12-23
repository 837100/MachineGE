//
//  DataManager.swift
//  MachineGE
//
//  Created by sg on 12/17/25.
//

import Foundation
import Combine

/// JSON 데이터를 로드하고 관리하는 매니저
class DataManager: ObservableObject {
    static let shared = DataManager()

    @Published var brands: [Brand] = []
    @Published var allEquipment: [EquipmentViewModel] = []

    // 브랜드 파일 목록
    private let brandFiles = [
        "hammerstrength",
 
    ]

    private init() {
        loadAllBrands()
    }

    // MARK: - 데이터 로드

    private func loadAllBrands() {
        var loadedBrands: [Brand] = []
        var loadedEquipment: [EquipmentViewModel] = []

        for brandFile in brandFiles {
            if let (brand, equipment) = loadBrandData(from: brandFile) {
                loadedBrands.append(brand)
                loadedEquipment.append(contentsOf: equipment)
            }
        }

        self.brands = loadedBrands
        self.allEquipment = loadedEquipment

        print("✅ 데이터 로드 완료: \(brands.count)개 브랜드, \(allEquipment.count)개 장비")
    }

    private func loadBrandData(from filename: String) -> (Brand, [EquipmentViewModel])? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("❌ \(filename).json 파일을 찾을 수 없습니다.")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let root = try decoder.decode(BrandDataRoot.self, from: data)

            let equipment = root.equipment.compactMap { item -> EquipmentViewModel? in
                guard let muscleGroup = MuscleGroup(rawValue: item.muscleGroup) else {
                    print("⚠️ 알 수 없는 근육 그룹: \(item.muscleGroup)")
                    return nil
                }

                let trajectory = parseTrajectory(muscleGroup: muscleGroup, trajectoryString: item.trajectory)
                let movement = parseMovement(muscleGroup: muscleGroup, movementString: item.movement)
                let position = Position(rawValue: item.position) ?? .seated

                return EquipmentViewModel(
                    id: item.id,
                    name: item.name,
                    brand: root.brand,
                    muscleGroup: muscleGroup,
                    trajectory: trajectory,
                    movement: movement,
                    position: position,
                    description: item.description,
                    targetMuscles: item.targetMuscles,
                    tips: item.tips, url: item.url
                )
            }

            return (root.brand, equipment)
        } catch {
            print("❌ \(filename).json 파싱 오류: \(error)")
            return nil
        }
    }

    // MARK: - 파싱 헬퍼

    private func parseTrajectory(muscleGroup: MuscleGroup, trajectoryString: String) -> Trajectory {
        switch muscleGroup {
        case .chest:
            if let t = ChestTrajectory(rawValue: trajectoryString) {
                return .chest(t)
            }
        case .back:
            if let t = BackTrajectory(rawValue: trajectoryString) {
                return .back(t)
            }
        case .shoulder:
            if let t = ShoulderTrajectory(rawValue: trajectoryString) {
                return .shoulder(t)
            }
        case .legs:
            if let t = StanceWidth(rawValue: trajectoryString) {
                return .legs(t)
            }
        case .arms:
            if let t = StanceWidth(rawValue: trajectoryString) {
                return .arms(t)
            }
        }
        // 기본값
        return .chest(.flat)
    }

    private func parseMovement(muscleGroup: MuscleGroup, movementString: String) -> Movement {
        switch muscleGroup {
        case .chest:
            if let m = ChestMovement(rawValue: movementString) {
                return .chest(m)
            }
        case .back:
            if let m = BackMovement(rawValue: movementString) {
                return .back(m)
            }
        case .shoulder:
            if let m = ShoulderMovement(rawValue: movementString) {
                return .shoulder(m)
            }
        case .legs:
            if let m = LegMovement(rawValue: movementString) {
                return .legs(m)
            }
        case .arms:
            if let m = ArmMovement(rawValue: movementString) {
                return .arms(m)
            }
        }
        // 기본값
        return .chest(.press)
    }

    // MARK: - 브랜드 관련

    /// 국내/해외별 브랜드 필터링
    func getBrands(origin: EquipmentOrigin?) -> [Brand] {
        guard let origin = origin else { return brands }
        return brands.filter { $0.origin == origin }
    }

    // MARK: - 장비 관련

    /// 브랜드별 장비 필터링
    func getEquipment(byBrandId brandId: String) -> [EquipmentViewModel] {
        allEquipment.filter { $0.brand.id == brandId }
    }

    /// 국내/해외별 장비 필터링
    func getEquipment(origin: EquipmentOrigin?) -> [EquipmentViewModel] {
        guard let origin = origin else { return allEquipment }
        return allEquipment.filter { $0.origin == origin }
    }

    /// 근육 그룹 + 궤적별 장비 필터링
    func getEquipment(byMuscleGroup muscleGroup: MuscleGroup, trajectory: Trajectory) -> [EquipmentViewModel] {
        allEquipment.filter { $0.muscleGroup == muscleGroup && $0.trajectory == trajectory }
    }

    /// 근육 그룹 + 동작별 장비 필터링
    func getEquipment(byMuscleGroup muscleGroup: MuscleGroup, movement: Movement) -> [EquipmentViewModel] {
        allEquipment.filter { $0.muscleGroup == muscleGroup && $0.movement == movement }
    }

    /// 자세별 장비 필터링
    func getEquipment(byPosition position: Position) -> [EquipmentViewModel] {
        allEquipment.filter { $0.position == position }
    }

    /// 근육 그룹 + 자세별 장비 필터링
    func getEquipment(byMuscleGroup muscleGroup: MuscleGroup, position: Position) -> [EquipmentViewModel] {
        allEquipment.filter { $0.muscleGroup == muscleGroup && $0.position == position }
    }
}
