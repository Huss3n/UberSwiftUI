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
    
    private var listener: ListenerRegistration?
    
    @Published var routeToPassenger: ShouldClearMap?
    @Published var cancelledTrip: Bool = false
    
    
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
                "isRideSent": userModel.isRideSent ?? false,
                "isRideAccepted": userModel.isRideAccepted ?? false,
                "routeToPassenger": userModel.routeToPassenger?.stringValue ?? "None"
            ]
            
            try await db.collection("users").document(userModel.userID).setData(userData)
        } catch {
            print("Error saving user data \(error.localizedDescription)")
        }
    }
    
    
    /*
     let userID: String
     let name: String
     let coordinates: CLLocationCoordinate2D
     let isDriver: Bool?
     let isRideSent: Bool?
     let isRideAccepted: Bool?
     let routeToPassenger: Bool?
     */
    
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
        let isRideSent = data["isRideSent"] as? Bool
        let isRideAccepted = data["isRideAccepted"] as? Bool
        let routeToPassenger = data["routeToPassenger"] as? ShouldClearMap
        let cancelledTrip = data["cancalledTrip"] as? Bool
        
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let userModel = UserModel(userID: userID, name: name, coordinates: coordinates, isDriver: isDriver, isRideSent: isRideSent, isRideAccepted: isRideAccepted, routeToPassenger: routeToPassenger, isCancelled: cancelledTrip)
        print(userModel)
        return userModel
    }
    
    func fetchPassengerCoordinates(completion: @escaping (CLLocationCoordinate2D?) -> Void) async {
        guard let rideRequestID = AuthManager.shared.getCurrentUserID() else { return }
        let db = Firestore.firestore()
        
        do {
            let docSnap = try await db.collection("users").document("84vZFDN0jDOS4nUUzO7EriK8fmT2").getDocument()
            guard let data = docSnap.data(),
                  let pickupCoordinates = data["coordinates"] as? [String: Double],
                  let latitude = pickupCoordinates["latitude"],
                  let longitude = pickupCoordinates["longitude"] else {
                print("No pickup coordinates found")
                completion(nil)
                return
            }
            
            let passengerLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            print("Pickup coordinates found, \(passengerLocation)")
            completion(passengerLocation)
            
        } catch {
            print("Error fetcing passenger coordinates")
            completion(nil)
        }
    }
    
    
    func startListenerForRoutePassenger() {
        let db = Firestore.firestore()
        // Listening to the collection or document
        listener = db.collection("users")
            .document("VbbNg4JpeBhiqYfmecER9PJRKan2")
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error?.localizedDescription ?? "Unknown")")
                    return
                }
                
                let routeToPassString = document.data()?["routeToPassenger"] as? String ?? "None"
                let routeToPass = ShouldClearMap(from: routeToPassString)
                DispatchQueue.main.async {
                    if self?.routeToPassenger != routeToPass {
                        self?.routeToPassenger = routeToPass
                        print("value of route to passenger updated")
                    }
                }
            }
    }
    
    
    func startListeningForCancelledTrip() {
        let db = Firestore.firestore()
        
        listener = db.collection("users")
            .document("VbbNg4JpeBhiqYfmecER9PJRKan2")
            .addSnapshotListener{ [weak self] documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document : \(error?.localizedDescription ?? "Unknown")")
                    return
                }
                
                let tripStatus = document.data()?["cancelTrip"] as? Bool ?? false
                
                DispatchQueue.main.async {
                    if self?.cancelledTrip != tripStatus {
                        self?.cancelledTrip = tripStatus
                    }
                }
            }
    }
    
    
}

