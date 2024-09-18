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
    private let db = Firestore.firestore()
    
    func findClosestDriver(userLocation: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
        db.collection("users")
            .whereField("isDriver", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching drivers: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No drivers found")
                    completion(nil)
                    return
                }
                
                var closestDriverID: String?
                var minimumDistance: CLLocationDistance = .greatestFiniteMagnitude
                
                for document in documents {
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
    }
    
    // Create a ride request by passing UserModel
    func createRideRequest(passenger: UserModel, destinationLocation: CLLocationCoordinate2D, completion: @escaping (Bool) -> Void) {
        findClosestDriver(userLocation: passenger.coordinates) { driverID in
            guard let driverID = driverID else {
                print("No driver available")
                completion(false)
                return
            }
            
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
                "status": "pending"
            ] as [String : Any]
            
            self.db.collection("rideRequests").addDocument(data: rideRequest) { error in
                if let error = error {
                    print("Error creating ride request: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Ride request sent to driver with ID: \(driverID)")
                    completion(true)
                }
            }
            
        }
    }
}


