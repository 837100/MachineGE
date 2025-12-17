//
//  DataManager.swift
//  MachineGE
//
//  Created by sg on 12/17/25.
//

import Foundation
internal import Combine

/// JSON 데이터를 로드하고 관리하는 매니저
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var brands: [Brand] = []
    @Published var equipment: [EquipmentItem] = []
    @Published var muscleGroups: [MuscleGroupInfo] = []
    @Published var movementPatterns: [MovementPatternInfo] = []
    
    private init() {
        loadData()
    }
    
    // MARK: - 데이터 로드
    
    private func loadData() {
        guard let url = Bundle.main.url(forResource: "EquipmentData", withExtension: "json") else {
            print("❌ EquipmentData.json 파일을 찾을 수 없습니다.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let root = try decoder.decode(EquipmentDataRoot.self, from: data)
            
            self.brands = root.brands
            self.equipment = root.equipment
            self.muscleGroups = root.muscleGroups
            self.movementPatterns = root.movementPatterns
            
            print("✅ 데이터 로드 완료: \(brands.count)개 브랜드, \(equipment.count)개 장비")
        } catch {
            print("❌ JSON 파싱 오류: \(error)")
        }
    }
    
    // MARK: - 브랜드 관련
    
    /// 브랜드 ID로 브랜드 찾기
    func getBrand(byId id: String) -> Brand? {
        brands.first { $0.id == id }
    }
    
    /// 국내/해외별 브랜드 필터링
    func getBrands(origin: EquipmentOrigin?) -> [Brand] {
        guard let origin = origin else { return brands }
        return brands.filter { $0.origin == origin }
    }
    
    // MARK: - 장비 관련
    
    /// 장비와 브랜드 정보가 결합된 뷰 모델 생성
    func getEquipmentViewModels() -> [EquipmentViewModel] {
        equipment.compactMap { item in
            guard let brand = getBrand(byId: item.brandId),
                  let muscleGroup = getMuscleGroup(byId: item.muscleGroup),
                  let pattern = getMovementPattern(byId: item.movementPattern) else {
                return nil
            }
            
            return EquipmentViewModel(
                id: item.id,
                name: item.name,
                brand: brand,
                muscleGroup: muscleGroup,
                movementPattern: pattern,
                description: item.description,
                targetMuscles: item.targetMuscles,
                tips: item.tips
            )
        }
    }
    
    /// 브랜드별 장비 필터링
    func getEquipment(byBrandId brandId: String) -> [EquipmentViewModel] {
        getEquipmentViewModels().filter { $0.brand.id == brandId }
    }
    
    /// 국내/해외별 장비 필터링
    func getEquipment(origin: EquipmentOrigin?) -> [EquipmentViewModel] {
        guard let origin = origin else { return getEquipmentViewModels() }
        return getEquipmentViewModels().filter { $0.origin == origin }
    }
    
    /// 근육 그룹별 장비 필터링
    func getEquipment(byMuscleGroup muscleGroupId: String) -> [EquipmentViewModel] {
        getEquipmentViewModels().filter { $0.muscleGroup.id == muscleGroupId }
    }
    
    /// 운동 궤적별 장비 필터링
    func getEquipment(byMovementPattern patternId: String) -> [EquipmentViewModel] {
        getEquipmentViewModels().filter { $0.movementPattern.id == patternId }
    }
    
    // MARK: - 근육 그룹 관련
    
    func getMuscleGroup(byId id: String) -> MuscleGroupInfo? {
        muscleGroups.first { $0.id == id }
    }
    
    // MARK: - 운동 궤적 관련
    
    func getMovementPattern(byId id: String) -> MovementPatternInfo? {
        movementPatterns.first { $0.id == id }
    }
}
