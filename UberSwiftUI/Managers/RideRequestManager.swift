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
    @Published var showPassengerPickUp = false
    @Published var passengerDetails: UserModel?
    
    
    var driverUID: String?
    
    private var listener: ListenerRegistration?
    private var isRideSentListener: ListenerRegistration?
    
    private let db = Firestore.firestore()
    
    func startListeningForRideRequests() {
        guard let driverUID = driverUID else {
            print("Driver UID is not set")
            return
        }

        let docRef = db.collection("users").document(driverUID)

        isRideSentListener = docRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            if let isRideSent = data["isRideSent"] as? Bool {
                DispatchQueue.main.async {
                    print("Is ride sent as per the listener is \(isRideSent)")
                    self?.showPassengerPickUp = isRideSent
                    
                    // Start listening for updates to the ride request if a ride is sent
                    if isRideSent, let rideRequestID = data["rideRequestID"] as? String {
                        self?.startListeningForRideRequestUpdates(rideRequestID: rideRequestID)
                    }
                }
            }
        }
    }

    func stopListeningForRideRequests() {
        isRideSentListener?.remove()
    }
        
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
    
//    func createRideRequest(passenger: UserModel, destinationLocation: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) async throws {
//        try await findClosestDriver(userLocation: passenger.coordinates) { driverID in
//            guard let driverID = driverID else {
//                print("No driver available")
//                completion(nil)
//                return
//            }
//            
//            self.driverUID = driverID
//            
//            let rideRequest = [
//                "passengerID": passenger.userID,
//                "passengerName": passenger.name,
//                "pickupCoordinates": [
//                    "latitude": passenger.coordinates.latitude,
//                    "longitude": passenger.coordinates.longitude
//                ],
//                "destinationCoordinates": [
//                    "latitude": destinationLocation.latitude,
//                    "longitude": destinationLocation.longitude
//                ],
//                "fareEstimate": 500, // Example fare
//                "requestTime": Date(),
//                "driverID": driverID,
//                "status": "pending"
//            ] as [String : Any]
//            
//            var requestRef: DocumentReference? = nil
//            requestRef = self.db.collection("rideRequests").addDocument(data: rideRequest) { error in
//                if let error = error {
//                    print("Error creating ride request: \(error.localizedDescription)")
//                    completion(nil)
//                } else {
//                    print("Ride request sent to driver with ID: \(driverID)")
//                    completion(requestRef?.documentID)
//                    
//                    Task {
//                        await self.updateIsRideSentValue()
//                        self.startListeningForRideRequests()
//                    }
//                }
//            }
//        }
//    }
    
    func createRideRequest(passenger: UserModel, destinationLocation: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) async throws {
        try await findClosestDriver(userLocation: passenger.coordinates) { driverID in
            guard let driverID = driverID else {
                print("No driver available")
                completion(nil)
                return
            }
            
            self.driverUID = driverID
            
            // Use RideState enum for status
            let rideRequest = [
                "passengerID": passenger.userID,
                "passengerName": passenger.name,
                "pickupCoordinates": [
                    "latitude": passenger.coordinates.latitude,
                    "longitude": passenger.coordinates.longitude
                ],
                "destinationCoordinates": [
                    "latitude": destinationLocation.latitude,
                    "longitude": destinationLocation.longitude
                ],
                "fareEstimate": 500, // Example fare
                "requestTime": Date(),
                "driverID": driverID,
                "status": RideState.pending.rawValue // Convert the enum to a string
            ] as [String: Any]
            
            var requestRef: DocumentReference? = nil
            requestRef = self.db.collection("rideRequests").addDocument(data: rideRequest) { error in
                if let error = error {
                    print("Error creating ride request: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    print("Ride request sent to driver with ID: \(driverID)")
                    completion(requestRef?.documentID)
                    
                    Task {
                        // Ensure that the document creation is complete before updating `isRideSent` and starting to listen for requests
                        await self.updateIsRideSentValue()
                        
                        // Now start listening for ride requests
                        self.startListeningForRideRequests()
                    }
                }
            }
        }
    }

    
    func startListeningForRideRequestUpdates(rideRequestID: String) {
        let docRef = Firestore.firestore().collection("rideRequests").document(rideRequestID)
        docRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let document = documentSnapshot, document.exists, let data = document.data() else {
                print("Error fetching ride request: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let passengerID = data["passengerID"] as? String {
                // Now fetch the passenger details
                Task {
                    await self?.fetchPassengerDetails(for: passengerID) {[weak self] passengerData in
                        self?.passengerDetails = passengerData
                        self?.showPassengerPickUp = true
                    }
                }
            }
        }
    }

    func fetchPassengerDetails(for passengerID: String, completion: @escaping (UserModel?) -> Void) async {
        do {
            guard let userModel = try await DatabaseManager.shared.fetchUserFromDatabase(for: passengerID) else { return }
            
            await MainActor.run {
                self.passengerDetails = userModel
            }
            
        } catch {
            print("Error fetching the data for the passenger, in the passenger details func at ride req")
        }
    }



    func updateIsRideSentValue() async {
        do {
            guard let driverUID else { return }
            let driverDocRef = Firestore.firestore().collection("users").document(driverUID)
            
            try await driverDocRef.updateData([
                "isRideSent": true
            ])
            print("Successfully updated isRideSent to true for driver: \(driverUID)")
        } catch {
            print("Error updating isRideSent: \(error.localizedDescription)")
        }
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
                    print(self.driverModel)
                    completion(true, driver)
                }
            }
        }
    }
    
    // MARK: When the driver accepts the ride
    func fetchDriverDetails(driverID: String, completion: @escaping (UserModel?) -> Void) {
        db.collection("users").document(driverID).getDocument { documentSnapshot, error in
            guard let document = documentSnapshot, document.exists, let data = document.data() else {
                print("Driver not found")
                completion(nil)
                return
            }
            
            if let name = data["name"] as? String,
               let coordinatesData = data["coordinates"] as? [String: Double],
               let latitude = coordinatesData["latitude"],
               let longitude = coordinatesData["longitude"] {
                
                let driver = UserModel(
                    userID: driverID,
                    name: name,
                    coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                )
                completion(driver)
            } else {
                completion(nil)
            }
        }
    }
    
    deinit {
        stopListeningForRideRequests()
        listener?.remove()
    }
}
