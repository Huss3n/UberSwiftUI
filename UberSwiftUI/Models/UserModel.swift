//
//  UserModel.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 11/09/2024.
//

import Foundation
import CoreLocation
import SwiftUI

import CoreLocation

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



 
