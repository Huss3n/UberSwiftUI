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
    
    func saveUserToDatabase(userModel: UserModel) async {
         let db = Firestore.firestore()
         let userData: [String: Any] = [
            "userID": userModel.userID,
            "name": userModel.name, // You can create a view where the user signs up with their name and save it. Keeping it simple
             "coordinates": [
                "latitude": userModel.coordinates.latitude,
                "longitude": userModel.coordinates.longitude
             ],
            "isDriver": userModel.isDriver
         ]
        
        do {
            try await db.collection("users").document(userModel.userID).setData(userData)
        } catch {
            print("Error saving user data \(error.localizedDescription)")
        }
     }
}
