//
//  LocationManager.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 24/08/2024.
//

import CoreLocation


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // only when the user is using the app
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // make sure the locations we are receiving is available
        guard !locations.isEmpty else { return }
        locationManager.stopUpdatingLocation()
    }
}

