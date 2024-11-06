//
//  BackendAuthService.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 12/10/2024.
//

import Foundation
import CoreLocation

class AuthService: ObservableObject {
    @Published var user: BackendUserModel?
    @Published var token: String?
    
    func signUpUser(name: String, email: String, password: String, coordinates: CLLocationCoordinate2D, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        
        let url = URL(string: "https://ef98-41-139-206-153.ngrok-free.app//signup")! // this is runs on my locaa host via ngrok
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Creating the request body
        let requestBody: [String: Any] = [
            "name": name,
            "email": email,
            "password": password,
            "coordinates": [
                "latitude": coordinates.latitude,
                "longitude": coordinates.longitude
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(.failure(error))
            return
        }

    }
    
    func loginUser(email: String, password: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        
        let url = URL(string: "https://3b54-41-90-40-60.ngrok-free.app/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Creating the request body
        let requestBody: [String: Any] = [
            "email": email,
            "password": password
        ]
    }
}

struct AuthResponse: Codable {
    let token: String
    let user: BackendUserModel
}

