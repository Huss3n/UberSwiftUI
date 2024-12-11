//
//  RideRequestManager.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 11/09/2024.
//

import Foundation
import FirebaseFirestore
import CoreLocation

final class RideRequestManager: ObservableObject {
    static let shared = RideRequestManager()
    
    @Published var driverModel: UserModel?
    //    @Published var showPassengerPickUp = false
    @Published var passengerDetails: UserModel?
    
    var driverUID: String?
    private var listener: ListenerRegistration?
    private var isRideSentListener: ListenerRegistration?
    
    private let db = Firestore.firestore()
    
    // MARK: - Ride Request Handling
    
    func createRideRequest(passenger: UserModel, destinationLocation: DestinationLocation, completion: @escaping (String?) -> Void) async throws {
        /*
        //        try await findClosestDriver(userLocation: passenger.coordinates) { driverID in
        //            guard let driverID = driverID else {
        //                print("No driver available")
        //                completion(nil)
        //                return
        //            }
        //        }
        */
        
        let driverUID = "VbbNg4JpeBhiqYfmecER9PJRKan2"
        
        let rideRequest = [
            "passengerID": passenger.userID,
            "passengerName": passenger.name,
            "pickupCoordinates": [
                "latitude": passenger.coordinates.latitude,
                "longitude": passenger.coordinates.longitude
            ],
            "destinationCoordinates": [
                "latitude": destinationLocation.coordinate.latitude,
                "longitude": destinationLocation.coordinate.longitude
            ],
            "destinationName": destinationLocation.name,
            "fareEstimate": 500,
            "requestTime": Date(),
            "driverID": driverUID,
            "status": RideState.pending.rawValue
        ] as [String: Any]
        
        let db = Firestore.firestore()
        try await db.collection("rideRequest").document("VbbNg4JpeBhiqYfmecER9PJRKan2").setData(rideRequest)
        
        Task {
            await self.updateIsRideSentValue(forDriver: driverUID)
        }
    }
    
    func updateIsRideSentValue(forDriver driverUID: String) async {
        do {
            let driverDocRef = Firestore.firestore().collection("users").document(driverUID)
            try await driverDocRef.updateData(["isRideSent": true])
            print("Successfully updated isRideSent to true for driver: \(driverUID)")
        } catch {
            print("Error updating isRideSent: \(error.localizedDescription)")
        }
    }
    
    
    
    // MARK: - Firestore Listeners - not used
    /*
     //    func startListeningForRideRequests() {
     //        guard let driverUID = driverUID else {
     //            print("Driver UID is not set")
     //            return
     //        }
     //
     //        let docRef = db.collection("users").document(driverUID)
     //
     //        isRideSentListener = docRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
     //            guard let document = documentSnapshot else {
     //                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
     //                return
     //            }
     //
     //            guard let data = document.data() else {
     //                print("Document data was empty.")
     //                return
     //            }
     //
     //            if let isRideSent = data["isRideSent"] as? Bool {
     //                DispatchQueue.main.async {
     ////                    self?.showPassengerPickUp = isRideSent
     //                    print("DEBUG: showPassengerPickUp set to \(isRideSent)")
     //                }
     //            }
     //        }
     //    }
     */
    /*
     func stopListeningForRideRequests() {
     isRideSentListener?.remove()
     isRideSentListener = nil
     }
     */
    
    // MARK: - User Data Fetching
    
    func fetchPassengerDetails(for passengerID: String, completion: @escaping (UserModel?) -> Void) async {
        
        // MARK: Remove hard coded id - used for debugging
        let hardcodedId = "84vZFDN0jDOS4nUUzO7EriK8fmT2"
        
        do {
            guard let userModel = try await DatabaseManager.shared.fetchUserFromDatabase(for: hardcodedId) else { return }
            await MainActor.run {
                self.passengerDetails = userModel
            }
        } catch {
            print("Error fetching passenger data: \(error.localizedDescription)")
        }
    }
    
    func fetchDriverDetails(driverID: String, completion: @escaping (UserModel?) -> Void) {
        // MARK: Remove hardcoded driver id - used for debugging
        let hardcodedDriverId  = "VbbNg4JpeBhiqYfmecER9PJRKan2"
        
        db.collection("users").document(hardcodedDriverId).getDocument { documentSnapshot, error in
            guard let document = documentSnapshot, document.exists, let data = document.data() else {
                print("Driver not found")
                completion(nil)
                return
            }
            
            if let name = data["name"] as? String,
               let coordinatesData = data["coordinates"] as? [String: Double],
               let latitude = coordinatesData["latitude"],
               let isDriver = data["isDriver"] as? Bool,
               let isRideSent = data["isRideSent"] as? Bool,
               let isRideAccepted = data["isRideAccepted"] as? Bool,
               let routeToPassenger = data["routeToPassenger"] as? ShouldClearMap,
               let cancelledTrip = data["cancalledTrip"] as? Bool,
               let longitude = coordinatesData["longitude"] {
                
                let driver = UserModel(userID: driverID, name: name, coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), isDriver: isDriver, isRideSent: isRideSent, isRideAccepted: isRideAccepted, routeToPassenger: routeToPassenger, isCancelled: cancelledTrip)
                completion(driver)
            } else {
                completion(nil)
            }
        }
    }
}



extension RideRequestManager {
    // testing the firebase listener
    func testListenerManually() {
        let docRef = db.collection("users").document("AbTIK4LfcOe21ho8e7XcMRupiH82")
        
        docRef.addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            if let isRideSent = data["isRideSent"] as? Bool {
                print("DEBUG: Manual test listener detected isRideSent = \(isRideSent)")
            }
        }
    }
    
    //    func stopTestListeningForRideRequests() {
    //        isRideSentListener?.remove()
    //        isRideSentListener = nil
    //        print("DEBUG: Firestore listener stopped")
    //    }
    
    //    func restartListeningForRideRequests() {
    //        stopListeningForRideRequests()
    //        startListeningForRideRequests()
    //    }
    
    
}

// MARK: Extras
extension RideRequestManager {
    
    // In RideRequestManager.swift
    //    func startListeningForRideRequestUpdates(rideRequestID: String) {
    //        let docRef = Firestore.firestore().collection("rideRequests").document(rideRequestID)
    //        docRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
    //            guard let document = documentSnapshot, document.exists, let data = document.data() else {
    //                print("Error fetching ride request: \(error?.localizedDescription ?? "Unknown error")")
    //                return
    //            }
    //
    //            // Update the showPassengerPickUp when isRideSent is true
    //            if let isRideSent = data["isRideSent"] as? Bool {
    //                DispatchQueue.main.async {
    //                    self?.showPassengerPickUp = isRideSent
    //                }
    //            }
    //
    //            // Check if the status is accepted
    //            if let status = data["status"] as? String, status == RideState.accepted.rawValue {
    //                DispatchQueue.main.async {
    //                    // Notify the HomeViewModel that the ride was accepted
    //                    NotificationCenter.default.post(name: Notification.Name("RideAccepted"), object: nil)
    //                }
    //            }
    //        }
    //    }
    
    func findClosestDriver(userLocation: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) async throws {
        let querySnapshot = try await db.collection("users").whereField("isDriver", isEqualTo: true).getDocuments()
        let docsSnapshot = querySnapshot.documents
        
        var closestDriverID: String?
        var minimumDistance: CLLocationDistance = .greatestFiniteMagnitude
        
        for document in docsSnapshot {
            let data = document.data()
            
            guard let coordinatesData = data["coordinates"] as? [String: Double],
                  let latitude = coordinatesData["latitude"],
                  let longitude = coordinatesData["longitude"] else {
                continue
            }
            
            let driverLocation = CLLocation(latitude: latitude, longitude: longitude)
            let userLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            
            let distance = userLocation.distance(from: driverLocation)
            
            if distance < minimumDistance {
                minimumDistance = distance
                closestDriverID = document.documentID
            }
        }
        completion(closestDriverID)
    }
    
    func listenForDriverAcceptance(rideRequestID: String, completion: @escaping (Bool, UserModel?) -> Void) {
        listener = db.collection("rideRequests").document(rideRequestID).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot, document.exists, let data = document.data() else {
                print("Ride request does not exist")
                completion(false, nil)
                return
            }
            
            if let status = data["status"] as? String, status == "accepted" {
                let driverID = data["driverID"] as? String ?? ""
                self.fetchDriverDetails(driverID: driverID) { driver in
                    self.driverModel = driver
                    //                    print(self.driverModel)
                    completion(true, driver)
                }
            }
        }
    }
    /*
    //    func startListeningForRideRequests() {
    //        guard let driverUID = driverUID else {
    //            print("Driver UID is not set")
    //            return
    //        }
    //
    //        print("DEBUG: Setting up listener for driver UID: \(driverUID)")
    //
    //        let docRef = db.collection("users").document(driverUID)
    //
    //        isRideSentListener = docRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
    //            guard let document = documentSnapshot else {
    //                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
    //                return
    //            }
    //
    //            guard let data = document.data() else {
    //                print("Document data was empty.")
    //                return
    //            }
    //
    //            if let isRideSent = data["isRideSent"] as? Bool {
    //                print("DEBUG: Listener detected isRideSent = \(isRideSent)")
    //                DispatchQueue.main.async {
    //                    if isRideSent {
    //                        self?.showPassengerPickUp = true
    //                        print("DEBUG: showPassengerPickUp set to true in RideRequestManager")
    //                    }
    //                }
    //            } else {
    //                print("DEBUG: isRideSent field not found in Firestore document")
    //            }
    //        }
    //    }
    
    //    func stopListeningForRideRequests() {
    //        isRideSentListener?.remove()
    //    }
    */
}
