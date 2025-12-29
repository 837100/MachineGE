//
//  BrandDetailView.swift
//  MachineGE
//
//  Created by sg on 12/29/25.
//

import SwiftUI


// MARK: - 브랜드 상세 뷰
struct BrandDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    let brand: Brand
    
    var brandEquipment: [EquipmentViewModel] {
        dataManager.getEquipment(byBrandId: brand.id)
    }
    
    var equipmentByMuscleGroup: [(MuscleGroup, [EquipmentViewModel])] {
        let grouped = Dictionary(grouping: brandEquipment) { $0.muscleGroup }
        return MuscleGroup.allCases.compactMap { muscleGroup in
            guard let equipment = grouped[muscleGroup], !equipment.isEmpty else { return nil }
            return (muscleGroup, equipment)
        }
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "building.2.fill")
                            .font(.largeTitle)
                            .foregroundStyle(brand.origin == .domestic ? .green : .orange)
                        
                        VStack(alignment: .leading) {
                            Text(brand.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(brand.nameEn)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Text(brand.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Label(brand.origin.rawValue, systemImage: "globe")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(brand.origin == .domestic ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                            .foregroundStyle(brand.origin == .domestic ? .green : .orange)
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        Text("\(brandEquipment.count)개 장비")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("브랜드 정보")
            }
            
            ForEach(equipmentByMuscleGroup, id: \.0) { muscleGroup, equipment in
                Section {
                    ForEach(equipment) { item in
                        NavigationLink {
                            EquipmentDetailView(equipment: item)
                        } label: {
                            EquipmentRowView(equipment: item)
                        }
                    }
                } header: {
                    Label(muscleGroup.displayName, systemImage: muscleGroup.icon)
                }
            }
        }
        .navigationTitle(brand.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
