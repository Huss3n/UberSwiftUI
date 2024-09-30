//
//  DatabaseManager.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 11/09/2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import CoreLocation

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    
    // Check if user exists in Firestore
    func doesUserExist(userID: String) async throws -> Bool {
        let db = Firestore.firestore()
        let docSnapshot = try await db.collection("users").document(userID).getDocument()
        
        return docSnapshot.exists
    }
    
    func saveUserToDatabase(userModel: UserModel) async {
        
        do {
            // Check if the user already exists
            let userExists = try await doesUserExist(userID: userModel.userID)
            
            if userExists {
                print("User already exists in Firestore, skipping save.")
                return
            }
            
            // If the user doesn't exist, proceed with saving
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "userID": userModel.userID,
                "name": userModel.name, // You can create a view where the user signs up with their name and save it. Keeping it simple
                "coordinates": [
                    "latitude": userModel.coordinates.latitude,
                    "longitude": userModel.coordinates.longitude
                ],
                "isDriver": userModel.isDriver ?? false,
                "isRideSent": userModel.isRideSent ?? false
            ]
            
            
            try await db.collection("users").document(userModel.userID).setData(userData)
        } catch {
            print("Error saving user data \(error.localizedDescription)")
        }
    }
    
    // fetch saved data
    func fetchUserFromDatabase(for userID: String) async throws -> UserModel? {
        let db = Firestore.firestore()
        let docSnapshot = try await db.collection("users").document(userID).getDocument()
        
        guard let data = docSnapshot.data() else {
            print("No data found for user ID: \(userID)")
            return nil
        }
        
        guard let name = data["name"] as? String,
              let isDriver = data["isDriver"] as? Bool,
              let coordinatesData = data["coordinates"] as? [String: Any],
              let latitude = coordinatesData["latitude"] as? CLLocationDegrees,
              let isDriver = data["isDriver"] as? Bool,
              let longitude = coordinatesData["longitude"] as? CLLocationDegrees else {
            print("Error parsing user data")
            return nil
        }
        
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let userModel = UserModel(userID: userID, name: name, coordinates: coordinates, isDriver: isDriver)
        print(userModel)
        return userModel
    }
    
}
