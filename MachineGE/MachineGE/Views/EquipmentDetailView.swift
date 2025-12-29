//
//  EquipmentDetailView.swift
//  MachineGE
//
//  Created by sg on 12/29/25.
//

import SwiftUI


// MARK: - 장비 상세 뷰
struct EquipmentDetailView: View {
    @StateObject private var viewModel: EquipmentDetailViewModel
    let equipment: EquipmentViewModel
    
    init(equipment: EquipmentViewModel) {
        self.equipment = equipment
        self._viewModel = StateObject(wrappedValue: EquipmentDetailViewModel(equipmentId: equipment.id))
    }
    
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
                    
                    Divider()
                    
                    // MARK: - 평점 섹션
                    RatingSectionView(viewModel: viewModel)
                    
                    Divider()
                    
                    // MARK: - 리뷰 섹션
                    ReviewSectionView(viewModel: viewModel)
                    
                    Divider()
                    
                    // MARK: - 보유 체육관 섹션
                    GymSectionView(viewModel: viewModel)
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
        .task {
            await viewModel.loadAllData()
        }
    }
}


// MARK: - 평점 섹션 뷰
struct RatingSectionView: View {
    @ObservedObject var viewModel: EquipmentDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⭐ 평점")
                .font(.headline)
            
            if viewModel.ratingSummary.totalReviews > 0 {
                HStack(spacing: 16) {
                    VStack {
                        Text(String(format: "%.1f", viewModel.ratingSummary.averageRating))
                            .font(.system(size: 48, weight: .bold))
                        
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= Int(viewModel.ratingSummary.averageRating.rounded()) ? "star.fill" : "star")
                                    .foregroundStyle(.yellow)
                                    .font(.caption)
                            }
                        }
                        
                        Text("\(viewModel.ratingSummary.totalReviews)개 리뷰")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // 별점 분포
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach((1...5).reversed(), id: \.self) { rating in
                            HStack(spacing: 4) {
                                Text("\(rating)")
                                    .font(.caption2)
                                    .frame(width: 10)
                                
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.gray.opacity(0.2))
                                        
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.yellow)
                                            .frame(width: geo.size.width * ratingPercentage(for: rating))
                                    }
                                }
                                .frame(width: 100, height: 8)
                                
                                Text("\(viewModel.ratingSummary.ratingDistribution[rating] ?? 0)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 25, alignment: .trailing)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Text("아직 평점이 없습니다")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
    }
    
    private func ratingPercentage(for rating: Int) -> CGFloat {
        guard viewModel.ratingSummary.totalReviews > 0 else { return 0 }
        let count = viewModel.ratingSummary.ratingDistribution[rating] ?? 0
        return CGFloat(count) / CGFloat(viewModel.ratingSummary.totalReviews)
    }
}

// MARK: - 리뷰 섹션 뷰
struct ReviewSectionView: View {
    @ObservedObject var viewModel: EquipmentDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("💬 리뷰")
                    .font(.headline)
                Spacer()
                Button("모두 보기") {
                    // TODO: 전체 리뷰 화면으로 이동
                }
                .font(.caption)
            }
            
            if viewModel.isLoadingReviews {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding()
            } else if viewModel.reviews.isEmpty {
                Text("아직 리뷰가 없습니다. 첫 리뷰를 남겨보세요!")
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ForEach(viewModel.reviews.prefix(3)) { review in
                    ReviewRowView(review: review)
                }
            }
            
            Button {
                // TODO: 리뷰 작성 화면
            } label: {
                HStack {
                    Image(systemName: "square.and.pencil")
                    Text("리뷰 작성하기")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .foregroundStyle(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

// MARK: - 리뷰 행 뷰
struct ReviewRowView: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.userName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= review.rating ? "star.fill" : "star")
                            .foregroundStyle(.yellow)
                            .font(.caption2)
                    }
                }
            }
            
            Text(review.comment)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(review.createdAt, style: .relative)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - 보유 체육관 섹션 뷰
struct GymSectionView: View {
    @ObservedObject var viewModel: EquipmentDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🏋️ 보유 체육관")
                    .font(.headline)
                Spacer()
                if !viewModel.gymsWithEquipment.isEmpty {
                    Button("지도로 보기") {
                        // TODO: 지도 화면으로 이동
                    }
                    .font(.caption)
                }
            }
            
            if viewModel.isLoadingGyms {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding()
            } else if viewModel.gymsWithEquipment.isEmpty {
                Text("등록된 체육관이 없습니다")
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ForEach(viewModel.gymsWithEquipment.prefix(3)) { gym in
                    GymRowView(gym: gym)
                }
                
                if viewModel.gymsWithEquipment.count > 3 {
                    Button {
                        // TODO: 전체 체육관 목록 화면
                    } label: {
                        Text("외 \(viewModel.gymsWithEquipment.count - 3)개 체육관 더보기")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
    }
}

// MARK: - 체육관 행 뷰
struct GymRowView: View {
    let gym: Gym
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "building.2")
                .font(.title2)
                .foregroundStyle(.green)
                .frame(width: 44, height: 44)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(gym.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(gym.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if let phone = gym.phoneNumber {
                Button {
                    if let url = URL(string: "tel://\(phone.replacingOccurrences(of: "-", with: ""))") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Image(systemName: "phone.fill")
                        .foregroundStyle(.green)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
