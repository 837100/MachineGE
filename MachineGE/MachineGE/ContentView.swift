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
                    Label("부위별", systemImage: "figure.strengthtraining.traditional")
                }
            
            PositionListView()
                .tabItem {
                    Label("자세별", systemImage: "figure.stand")
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
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.brand.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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

// MARK: - 장비 행 뷰
struct EquipmentRowView: View {
    let equipment: EquipmentViewModel

    var body: some View {
        HStack(spacing: 12) {
            // 브랜드 로고가 있으면 로고를 원형으로 표시
            if let logoUrlStr = equipment.brand.imageUrl, let logoUrl = URL(string: logoUrlStr) {
                RemoteImageView(pageURL: logoUrl, contentMode: .fit) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 40, height: 40)
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Image(systemName: equipment.muscleGroup.icon)
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(equipment.name)
                    .font(.headline)
                HStack(spacing: 4) {
                    Text(equipment.brand.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("•")
                        .foregroundStyle(.secondary)

                    Text(equipment.position.displayName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())

                    Text(equipment.trajectory.displayName)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.purple.opacity(0.1))
                        .foregroundStyle(.purple)
                        .clipShape(Capsule())
                }
            }

            Spacer()
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
                // 우선: equipment.url을 사용하여 해당 장비 페이지(또는 직접 이미지)를 기반으로 대표 이미지를 가져옴
                if let equipmentUrlStr = equipment.url, let equipmentUrl = URL(string: equipmentUrlStr) {
                    RemoteImageView(pageURL: equipmentUrl, contentMode: .fill) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.gradient)
                                .frame(height: 200)
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaleEffect(1.2)
                        }
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }
                // 그 다음으로 브랜드 로고(이미지)가 있으면 표시
                else if let imgUrlStr = equipment.brand.imageUrl, let imgUrl = URL(string: imgUrlStr) {
                    RemoteImageView(pageURL: imgUrl, contentMode: .fill) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.gradient)
                                .frame(height: 200)
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaleEffect(1.2)
                        }
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }
                // 그 다음 브랜드 웹사이트에서 대표 이미지 추출
                else if let website = equipment.brand.website, let websiteUrl = URL(string: website) {
                    RemoteImageView(pageURL: websiteUrl, contentMode: .fill) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.gradient)
                                .frame(height: 200)
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaleEffect(1.2)
                        }
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                } else {
                    // 기존 기본 카드
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.gradient)
                            .frame(height: 200)

                        Image(systemName: equipment.muscleGroup.icon)
                            .font(.system(size: 80))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    InfoRow(title: "브랜드", value: "\(equipment.brand.name) (\(equipment.brand.nameEn))")
                    InfoRow(title: "타겟 부위", value: equipment.muscleGroup.displayName)
                    InfoRow(title: "자세", value: equipment.position.displayName)
                    InfoRow(title: "궤적", value: equipment.trajectory.displayName)
                    InfoRow(title: "동작", value: equipment.movement.displayName)
                    
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

// MARK: - Flow Layout
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

// MARK: - 부위별 뷰
struct MuscleGroupView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(MuscleGroup.allCases) { muscle in
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
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(muscle.displayName)
                                    .font(.headline)
                                Text(muscle.trajectories.map { $0.displayName }.joined(separator: " • "))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("💪 부위별 운동")
        }
    }
}

// MARK: - 부위 상세 뷰
struct MuscleDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    let muscleGroup: MuscleGroup
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("보기", selection: $selectedTab) {
                Text("궤적별").tag(0)
                Text("동작별").tag(1)
                Text("자세별").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            switch selectedTab {
            case 0:
                TrajectoryListView(muscleGroup: muscleGroup)
            case 1:
                MovementListView(muscleGroup: muscleGroup)
            default:
                PositionFilteredListView(muscleGroup: muscleGroup)
            }
        }
        .navigationTitle("\(muscleGroup.displayName) 운동")
    }
}

// MARK: - 궤적별 리스트
struct TrajectoryListView: View {
    @EnvironmentObject var dataManager: DataManager
    let muscleGroup: MuscleGroup
    
    var body: some View {
        List {
            ForEach(muscleGroup.trajectories) { trajectory in
                let equipment = dataManager.getEquipment(byMuscleGroup: muscleGroup, trajectory: trajectory)
                if !equipment.isEmpty {
                    Section {
                        ForEach(equipment) { item in
                            NavigationLink {
                                EquipmentDetailView(equipment: item)
                            } label: {
                                EquipmentRowView(equipment: item)
                            }
                        }
                    } header: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(trajectory.displayName)
                                .font(.headline)
                            Text(trajectory.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 동작별 리스트
struct MovementListView: View {
    @EnvironmentObject var dataManager: DataManager
    let muscleGroup: MuscleGroup
    
    var body: some View {
        List {
            ForEach(muscleGroup.movements) { movement in
                let equipment = dataManager.getEquipment(byMuscleGroup: muscleGroup, movement: movement)
                if !equipment.isEmpty {
                    Section {
                        ForEach(equipment) { item in
                            NavigationLink {
                                EquipmentDetailView(equipment: item)
                            } label: {
                                EquipmentRowView(equipment: item)
                            }
                        }
                    } header: {
                        Text(movement.displayName)
                            .font(.headline)
                    }
                }
            }
        }
    }
}

// MARK: - 자세별 필터 리스트
struct PositionFilteredListView: View {
    @EnvironmentObject var dataManager: DataManager
    let muscleGroup: MuscleGroup
    
    var body: some View {
        List {
            ForEach(Position.allCases) { position in
                let equipment = dataManager.getEquipment(byMuscleGroup: muscleGroup, position: position)
                if !equipment.isEmpty {
                    Section {
                        ForEach(equipment) { item in
                            NavigationLink {
                                EquipmentDetailView(equipment: item)
                            } label: {
                                EquipmentRowView(equipment: item)
                            }
                        }
                    } header: {
                        Label(position.displayName, systemImage: position.icon)
                            .font(.headline)
                    }
                }
            }
        }
    }
}

// MARK: - 자세별 전체 뷰 (탭)
struct PositionListView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Position.allCases) { position in
                    NavigationLink {
                        PositionDetailView(position: position)
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: position.icon)
                                .font(.title)
                                .foregroundStyle(.green)
                                .frame(width: 50, height: 50)
                                .background(Color.green.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(position.displayName)
                                    .font(.headline)
                                Text(position.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("🧘 자세별 운동")
        }
    }
}

// MARK: - 자세 상세 뷰
struct PositionDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    let position: Position
    
    var filteredEquipment: [EquipmentViewModel] {
        dataManager.getEquipment(byPosition: position)
    }
    
    var equipmentByMuscleGroup: [(MuscleGroup, [EquipmentViewModel])] {
        let grouped = Dictionary(grouping: filteredEquipment) { $0.muscleGroup }
        return MuscleGroup.allCases.compactMap { muscleGroup in
            guard let equipment = grouped[muscleGroup], !equipment.isEmpty else { return nil }
            return (muscleGroup, equipment)
        }
    }
    
    var body: some View {
        List {
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
        .navigationTitle("\(position.displayName) 운동")
    }
}

#Preview {
    ContentView()
}
