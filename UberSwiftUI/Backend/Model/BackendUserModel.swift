//
//  BackendUserModel.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 12/10/2024.
//

import Foundation
import CoreLocation

struct BackendUserModel: Codable {
    let userID: String
    let name: String
    let latitude: Double
    let longitude: Double
    let isDriver: Bool?
    let isRideSent: Bool?

    // Custom initializer to use CLLocationCoordinate2D for coordinates
    init(userID: String, name: String, coordinates: CLLocationCoordinate2D, isDriver: Bool? = nil, isRideSent: Bool? = nil) {
        self.userID = userID
        self.name = name
        self.latitude = coordinates.latitude
        self.longitude = coordinates.longitude
        self.isDriver = isDriver
        self.isRideSent = isRideSent
    }
    
    // Method to retrieve CLLocationCoordinate2D from latitude and longitude
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/*
struct UserModel {
    let userID: String
    let name: String
    let coordinates: CLLocationCoordinate2D
    let isDriver: Bool?
    let isRideSent: Bool?

    // Initializer
    init(userID: String, name: String, coordinates: CLLocationCoordinate2D, isDriver: Bool? = nil, isRideSent: Bool? = nil) {
        self.userID = userID
        self.name = name
        self.coordinates = coordinates
        self.isDriver = isDriver
        self.isRideSent = isRideSent
    }
}
*/
