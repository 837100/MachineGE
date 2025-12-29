//
//  GymInfo.swift
//  MachineGE
//
//  Created by sg on 12/29/25.
//

import Foundation

// MARK: - 체육관 정보 모델
struct GymInfo: Identifiable, Codable {
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
