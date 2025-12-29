//
//  EquipmentRowView.swift
//  MachineGE
//
//  Created by sg on 12/29/25.
//

import SwiftUI


// MARK: - 장비 행 뷰
struct EquipmentRowView: View {
    let equipment: EquipmentViewModel

    var body: some View {
        HStack(spacing: 12) {
            // EquipmentImageView: 로컬 이미지면 Assets에서, http로 시작하면 외부에서 로드
            EquipmentImageView(imageSource: equipment.brand.imageUrl, contentMode: .fit) {
                Image(systemName: equipment.muscleGroup.icon)
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

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
