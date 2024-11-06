//
//  BackendConfig.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 12/10/2024.
//

import Foundation

struct BackendConfig {
    static let baseURL = "https://3b54-41-90-40-60.ngrok-free.app" // replace with your actual backend URL or ngrok url
    static let signupURL = URL(string: "\(baseURL)/signup")!
    static let loginURL = URL(string: "\(baseURL)/login")!
    static let requestRideURL = URL(string: "\(baseURL)/ride/request")!
    static let acceptRideURL = URL(string: "\(baseURL)/ride/accept")!
    static let fetchRidesURL = URL(string: "\(baseURL)/rides")!
}
