//
//  MapState.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 26/08/2024.
//

import Foundation


enum MapState: Identifiable {
    case noInput
    case locationSelected
    case searchingForLocation
    case profile
    
    var id: Int {
        hashValue
    }
}
