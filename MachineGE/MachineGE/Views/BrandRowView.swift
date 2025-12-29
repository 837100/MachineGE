//
//  BrandRowView.swift
//  MachineGE
//
//  Created by sg on 12/29/25.
//

import SwiftUI


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
