//
//  EquipmentListView.swift
//  MachineGE
//
//  Created by sg on 12/29/25.
//

import SwiftUI


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
