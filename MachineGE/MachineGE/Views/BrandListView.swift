//
//  BrandListView.swift
//  MachineGE
//
//  Created by sg on 12/29/25.
//

import SwiftUI


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
