//
//  ContentView.swift
//  MachineGE
//
//  Created by sg on 12/17/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        TabView {
            EquipmentListView()
                .tabItem {
                    Label("장비 목록", systemImage: "dumbbell.fill")
                }
            
            BrandListView()
                .tabItem {
                    Label("브랜드별", systemImage: "building.2.fill")
                }
            
            MuscleGroupView()
                .tabItem {
                    Label("주동근별", systemImage: "figure.strengthtraining.traditional")
                }
            
            MovementPatternView()
                .tabItem {
                    Label("궤적별", systemImage: "arrow.triangle.2.circlepath")
                }
        }
        .environmentObject(dataManager)
    }
}

// MARK: - 장비 목록 뷰
struct EquipmentListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedOrigin: EquipmentOrigin? = nil
    @State private var searchText = ""
    
    var filteredEquipment: [EquipmentViewModel] {
        let equipmentList = dataManager.getEquipment(origin: selectedOrigin)
        if searchText.isEmpty {
            return equipmentList
        }
        return equipmentList.filter {
            $0.name.contains(searchText) || $0.brand.name.contains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 국내/해외 필터
                Picker("장비 유형", selection: $selectedOrigin) {
                    Text("전체").tag(nil as EquipmentOrigin?)
                    ForEach(EquipmentOrigin.allCases, id: \.self) { origin in
                        Text(origin.rawValue).tag(origin as EquipmentOrigin?)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                List(filteredEquipment) { equipment in
                    NavigationLink {
                        EquipmentDetailView(equipment: equipment)
                    } label: {
                        EquipmentRowView(equipment: equipment)
                    }
                }
            }
            .navigationTitle("🏋️ 장비 목록")
            .searchable(text: $searchText, prompt: "장비 또는 브랜드 검색")
        }
    }
}

// MARK: - 브랜드 목록 뷰
struct BrandListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedOrigin: EquipmentOrigin? = nil
    
    var filteredBrands: [Brand] {
        dataManager.getBrands(origin: selectedOrigin)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("브랜드 유형", selection: $selectedOrigin) {
                    Text("전체").tag(nil as EquipmentOrigin?)
                    ForEach(EquipmentOrigin.allCases, id: \.self) { origin in
                        Text(origin.rawValue).tag(origin as EquipmentOrigin?)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                List(filteredBrands) { brand in
                    NavigationLink {
                        BrandDetailView(brand: brand)
                    } label: {
                        BrandRowView(brand: brand)
                    }
                }
            }
            .navigationTitle("🏭 브랜드별")
        }
    }
}

// MARK: - 브랜드 행 뷰
struct BrandRowView: View {
    let brand: Brand
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "building.2.fill")
                .font(.title2)
                .foregroundStyle(brand.origin == .domestic ? .green : .orange)
                .frame(width: 40, height: 40)
                .background(brand.origin == .domestic ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(brand.name)
                    .font(.headline)
                HStack {
                    Text(brand.nameEn)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text(brand.origin.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(brand.origin == .domestic ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                        .foregroundStyle(brand.origin == .domestic ? .green : .orange)
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 브랜드 상세 뷰
struct BrandDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    let brand: Brand
    
    var brandEquipment: [EquipmentViewModel] {
        dataManager.getEquipment(byBrandId: brand.id)
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
            
            Section {
                ForEach(brandEquipment) { equipment in
                    NavigationLink {
                        EquipmentDetailView(equipment: equipment)
                    } label: {
                        EquipmentRowView(equipment: equipment)
                    }
                }
            } header: {
                Text("장비 목록")
            }
        }
        .navigationTitle(brand.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 장비 행 뷰
struct EquipmentRowView: View {
    let equipment: EquipmentViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: equipment.muscleGroup.icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(equipment.name)
                    .font(.headline)
                HStack {
                    Text(equipment.brand.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text(equipment.origin.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(equipment.origin == .domestic ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                        .foregroundStyle(equipment.origin == .domestic ? .green : .orange)
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            Text(equipment.muscleGroup.name)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 장비 상세 뷰
struct EquipmentDetailView: View {
    let equipment: EquipmentViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 헤더 이미지 대체
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue.gradient)
                        .frame(height: 200)
                    
                    Image(systemName: equipment.muscleGroup.icon)
                        .font(.system(size: 80))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.horizontal)
                
                // 정보 카드
                VStack(alignment: .leading, spacing: 16) {
                    InfoRow(title: "브랜드", value: "\(equipment.brand.name) (\(equipment.brand.nameEn))")
                    InfoRow(title: "타겟 근육", value: equipment.muscleGroup.name)
                    InfoRow(title: "운동 궤적", value: equipment.movementPattern.name)
                    InfoRow(title: "제조 국가", value: equipment.origin.rawValue)
                    
                    Divider()
                    
                    Text("설명")
                        .font(.headline)
                    Text(equipment.description)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    Text("타겟 근육")
                        .font(.headline)
                    FlowLayout(spacing: 8) {
                        ForEach(equipment.targetMuscles, id: \.self) { muscle in
                            Text(muscle)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Divider()
                    
                    Text("💡 운동 팁")
                        .font(.headline)
                    Text(equipment.tips)
                        .foregroundStyle(.secondary)
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 2)
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .navigationTitle(equipment.name)
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Flow Layout (태그 표시용)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return CGSize(width: proposal.width ?? 0, height: result.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var positions: [CGPoint] = []
        var height: CGFloat = 0
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > width && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            
            height = y + rowHeight
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - 주동근별 뷰
struct MuscleGroupView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dataManager.muscleGroups) { muscle in
                    NavigationLink {
                        MuscleDetailView(muscleGroup: muscle)
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: muscle.icon)
                                .font(.title)
                                .foregroundStyle(.blue)
                                .frame(width: 50, height: 50)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            Text(muscle.name)
                                .font(.headline)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("💪 주동근별 운동")
        }
    }
}

struct MuscleDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    let muscleGroup: MuscleGroupInfo
    
    var filteredEquipment: [EquipmentViewModel] {
        dataManager.getEquipment(byMuscleGroup: muscleGroup.id)
    }
    
    var body: some View {
        List(filteredEquipment) { equipment in
            NavigationLink {
                EquipmentDetailView(equipment: equipment)
            } label: {
                EquipmentRowView(equipment: equipment)
            }
        }
        .navigationTitle("\(muscleGroup.name) 운동")
    }
}

// MARK: - 궤적별 뷰
struct MovementPatternView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dataManager.movementPatterns) { pattern in
                    NavigationLink {
                        PatternDetailView(pattern: pattern)
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: iconForPattern(pattern.id))
                                .font(.title)
                                .foregroundStyle(.purple)
                                .frame(width: 50, height: 50)
                                .background(Color.purple.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            VStack(alignment: .leading) {
                                Text(pattern.name)
                                    .font(.headline)
                                Text(pattern.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("🔄 비슷한 궤적")
        }
    }
    
    func iconForPattern(_ patternId: String) -> String {
        switch patternId {
        case "push": return "arrow.right.circle.fill"
        case "pull": return "arrow.left.circle.fill"
        case "press": return "arrow.up.circle.fill"
        case "curl": return "arrow.uturn.up.circle.fill"
        case "extension": return "arrow.uturn.down.circle.fill"
        case "squat": return "arrow.down.circle.fill"
        case "deadlift": return "arrow.up.arrow.down.circle.fill"
        case "row": return "arrow.left.and.right.circle.fill"
        default: return "circle.fill"
        }
    }
}

struct PatternDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    let pattern: MovementPatternInfo
    
    var filteredEquipment: [EquipmentViewModel] {
        dataManager.getEquipment(byMovementPattern: pattern.id)
    }
    
    var body: some View {
        List(filteredEquipment) { equipment in
            NavigationLink {
                EquipmentDetailView(equipment: equipment)
            } label: {
                EquipmentRowView(equipment: equipment)
            }
        }
        .navigationTitle("\(pattern.name) 동작")
    }
}

#Preview {
    ContentView()
}
