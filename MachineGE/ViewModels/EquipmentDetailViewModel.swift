//
//  EquipmentDetailViewModel.swift
//  MachineGE
//
//  Created by sg on 12/29/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Firebase 데이터 모델

/// 사용자 리뷰 모델
struct Review: Identifiable, Codable {
    var id: String = UUID().uuidString
    let userId: String
    let userName: String
    let rating: Int          // 1~5 별점
    let comment: String
    let createdAt: Date
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, userId, userName, rating, comment, createdAt, updatedAt
    }
}

/// 체육관 정보 모델
struct Gym: Identifiable, Codable {
    var id: String = UUID().uuidString
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let phoneNumber: String?
    let website: String?
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, address, latitude, longitude, phoneNumber, website, imageUrl
    }
}

/// 장비 평점 요약 모델
struct RatingSummary: Codable {
    let averageRating: Double
    let totalReviews: Int
    let ratingDistribution: [Int: Int]  // 별점별 개수 (1~5)
    
    static let empty = RatingSummary(averageRating: 0, totalReviews: 0, ratingDistribution: [:])
}

// MARK: - ViewModel

@MainActor
class EquipmentDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// 평점 요약
    @Published var ratingSummary: RatingSummary = .empty
    
    /// 리뷰 목록
    @Published var reviews: [Review] = []
    
    /// 해당 장비를 보유한 체육관 목록
    @Published var gymsWithEquipment: [Gym] = []
    
    /// 로딩 상태
    @Published var isLoadingReviews: Bool = false
    @Published var isLoadingGyms: Bool = false
    
    /// 에러 메시지
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let equipmentId: String
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(equipmentId: String) {
        self.equipmentId = equipmentId
    }
    
    // MARK: - Public Methods
    
    /// 모든 데이터 로드
    func loadAllData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchRatingSummary() }
            group.addTask { await self.fetchReviews() }
            group.addTask { await self.fetchGymsWithEquipment() }
        }
    }
    
    /// 평점 요약 가져오기
    func fetchRatingSummary() async {
        // TODO: Firebase Firestore 연동
        // let db = Firestore.firestore()
        // let docRef = db.collection("equipment").document(equipmentId).collection("ratings").document("summary")
        
        // 임시 더미 데이터
        do {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5초 딜레이 시뮬레이션
            
            ratingSummary = RatingSummary(
                averageRating: 4.2,
                totalReviews: 128,
                ratingDistribution: [5: 64, 4: 38, 3: 18, 2: 5, 1: 3]
            )
        } catch {
            errorMessage = "평점 정보를 불러오는데 실패했습니다: \(error.localizedDescription)"
        }
    }
    
    /// 리뷰 목록 가져오기
    func fetchReviews(limit: Int = 10) async {
        isLoadingReviews = true
        defer { isLoadingReviews = false }
        
        // TODO: Firebase Firestore 연동
        // let db = Firestore.firestore()
        // let query = db.collection("equipment").document(equipmentId)
        //     .collection("reviews")
        //     .order(by: "createdAt", descending: true)
        //     .limit(to: limit)
        
        // 임시 더미 데이터
        do {
            try await Task.sleep(nanoseconds: 800_000_000) // 0.8초 딜레이 시뮬레이션
            
            reviews = [
                Review(
                    id: "1",
                    userId: "user1",
                    userName: "운동매니아",
                    rating: 5,
                    comment: "가슴 운동 중 최고의 머신입니다. 궤적이 자연스럽고 어깨에 부담이 적어요.",
                    createdAt: Date().addingTimeInterval(-86400),
                    updatedAt: nil
                ),
                Review(
                    id: "2",
                    userId: "user2",
                    userName: "헬스초보",
                    rating: 4,
                    comment: "처음 사용하기에도 좋습니다. 다만 무게 조절이 조금 불편해요.",
                    createdAt: Date().addingTimeInterval(-172800),
                    updatedAt: nil
                ),
                Review(
                    id: "3",
                    userId: "user3",
                    userName: "보디빌더Kim",
                    rating: 5,
                    comment: "해머스트렝스 특유의 독립 암으로 좌우 균형 잡기에 최고입니다.",
                    createdAt: Date().addingTimeInterval(-259200),
                    updatedAt: nil
                )
            ]
        } catch {
            errorMessage = "리뷰를 불러오는데 실패했습니다: \(error.localizedDescription)"
        }
    }
    
    /// 해당 장비를 보유한 체육관 목록 가져오기
    func fetchGymsWithEquipment() async {
        isLoadingGyms = true
        defer { isLoadingGyms = false }
        
        // TODO: Firebase Firestore 연동
        // let db = Firestore.firestore()
        // let query = db.collection("gyms")
        //     .whereField("equipmentIds", arrayContains: equipmentId)
        
        // 임시 더미 데이터
        do {
            try await Task.sleep(nanoseconds: 600_000_000) // 0.6초 딜레이 시뮬레이션
            
            gymsWithEquipment = [
                Gym(
                    id: "gym1",
                    name: "스포애니 강남점",
                    address: "서울시 강남구 테헤란로 123",
                    latitude: 37.5012,
                    longitude: 127.0396,
                    phoneNumber: "02-1234-5678",
                    website: "https://www.spoany.co.kr",
                    imageUrl: nil
                ),
                Gym(
                    id: "gym2",
                    name: "에니타임피트니스 역삼점",
                    address: "서울시 강남구 역삼로 456",
                    latitude: 37.4995,
                    longitude: 127.0365,
                    phoneNumber: "02-2345-6789",
                    website: "https://www.anytimefitness.co.kr",
                    imageUrl: nil
                ),
                Gym(
                    id: "gym3",
                    name: "월드짐 선릉점",
                    address: "서울시 강남구 선릉로 789",
                    latitude: 37.5045,
                    longitude: 127.0489,
                    phoneNumber: "02-3456-7890",
                    website: nil,
                    imageUrl: nil
                )
            ]
        } catch {
            errorMessage = "체육관 정보를 불러오는데 실패했습니다: \(error.localizedDescription)"
        }
    }
    
    /// 리뷰 추가하기
    func addReview(rating: Int, comment: String, userId: String, userName: String) async -> Bool {
        // TODO: Firebase Firestore 연동
        // let db = Firestore.firestore()
        // let reviewRef = db.collection("equipment").document(equipmentId).collection("reviews").document()
        
        let newReview = Review(
            id: UUID().uuidString,
            userId: userId,
            userName: userName,
            rating: rating,
            comment: comment,
            createdAt: Date(),
            updatedAt: nil
        )
        
        do {
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3초 딜레이 시뮬레이션
            
            // 로컬에 추가 (실제로는 Firebase에 저장 후 리스너로 업데이트)
            reviews.insert(newReview, at: 0)
            
            // 평점 요약 업데이트
            let newTotal = ratingSummary.totalReviews + 1
            let newAverage = (ratingSummary.averageRating * Double(ratingSummary.totalReviews) + Double(rating)) / Double(newTotal)
            var newDistribution = ratingSummary.ratingDistribution
            newDistribution[rating, default: 0] += 1
            
            ratingSummary = RatingSummary(
                averageRating: newAverage,
                totalReviews: newTotal,
                ratingDistribution: newDistribution
            )
            
            return true
        } catch {
            errorMessage = "리뷰 등록에 실패했습니다: \(error.localizedDescription)"
            return false
        }
    }
    
    /// 더 많은 리뷰 로드 (페이지네이션)
    func loadMoreReviews() async {
        guard !isLoadingReviews else { return }
        
        // TODO: Firebase Firestore 페이지네이션 구현
        // 마지막 문서 기준으로 다음 페이지 로드
    }
}

// MARK: - Preview Helper

extension EquipmentDetailViewModel {
    static var preview: EquipmentDetailViewModel {
        let vm = EquipmentDetailViewModel(equipmentId: "preview-equipment")
        vm.ratingSummary = RatingSummary(
            averageRating: 4.5,
            totalReviews: 42,
            ratingDistribution: [5: 20, 4: 15, 3: 5, 2: 1, 1: 1]
        )
        vm.reviews = [
            Review(id: "1", userId: "u1", userName: "테스터", rating: 5, comment: "좋아요!", createdAt: Date(), updatedAt: nil)
        ]
        vm.gymsWithEquipment = [
            Gym(id: "g1", name: "테스트헬스장", address: "서울시 강남구", latitude: 37.5, longitude: 127.0, phoneNumber: nil, website: nil, imageUrl: nil)
        ]
        return vm
    }
}
