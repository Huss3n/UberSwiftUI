//
//  RideRequestModel.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 19/09/2024.
//

import Foundation
import CoreLocation
import FirebaseFirestore

struct RideRequestModel {
    let passengerID: String
    let passengerName: String
    let pickupCoordinates: CLLocationCoordinate2D
    let destinationCoordinates: CLLocationCoordinate2D
    let fareEstimate: Double
    let requestTime: Date
    let driverID: String
    let status: String
    

    init?(from data: [String: Any]?) {
        guard let data = data,
              let passengerID = data["passengerID"] as? String,
              let passengerName = data["passengerName"] as? String,
              let pickupCoords = data["pickupCoordinates"] as? [String: Double],
              let destCoords = data["destinationCoordinates"] as? [String: Double],
              let fareEstimate = data["fareEstimate"] as? Double,
              let requestTime = data["requestTime"] as? Timestamp,
              let driverID = data["driverID"] as? String,
              let status = data["status"] as? String,
              let pickupLatitude = pickupCoords["latitude"],
              let pickupLongitude = pickupCoords["longitude"],
              let destLatitude = destCoords["latitude"],
              let destLongitude = destCoords["longitude"] else {
            return nil
        }
        
        self.passengerID = passengerID
        self.passengerName = passengerName
        self.pickupCoordinates = CLLocationCoordinate2D(latitude: pickupLatitude, longitude: pickupLongitude)
        self.destinationCoordinates = CLLocationCoordinate2D(latitude: destLatitude, longitude: destLongitude)
        self.fareEstimate = fareEstimate
        self.requestTime = requestTime.dateValue()
        self.driverID = driverID
        self.status = status
    }
    

    func toDictionary() -> [String: Any] {
        return [
            "passengerID": passengerID,
            "passengerName": passengerName,
            "pickupCoordinates": [
                "latitude": pickupCoordinates.latitude,
                "longitude": pickupCoordinates.longitude
            ],
            "destinationCoordinates": [
                "latitude": destinationCoordinates.latitude,
                "longitude": destinationCoordinates.longitude
            ],
            "fareEstimate": fareEstimate,
            "requestTime": Timestamp(date: requestTime),
            "driverID": driverID,
            "status": status
        ]
    }
}
