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
