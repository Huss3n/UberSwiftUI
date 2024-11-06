//
//  BackendRideModel.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 12/10/2024.
//

import Foundation


struct BackendRideModel: Codable, Identifiable {
    let id: String
    let passenger_id: String
    let pickup_location: String
    let destination_location: String
    var status: String
    var created_at: Date?
    var driver_id: String?
}

