//
//  UserModel.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 11/09/2024.
//

import Foundation
import CoreLocation
import SwiftUI

struct UserModel {
    let userID: String
    let name: String
    let coordinates: CLLocationCoordinate2D
    let isDriver: Bool = false
}


