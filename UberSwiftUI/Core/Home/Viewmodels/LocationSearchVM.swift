//
//  LocationSearchVM.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 26/08/2024.
//

import Foundation
import MapKit

final class LocationSearchVM: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    @Published var results: [MKLocalSearchCompletion] = []
    private var searchCompleter = MKLocalSearchCompleter()
    @Published var selectedTripLocation:  TripLocation?
    
    @Published var pickupTime: String?
    @Published var dropoffTime: String?
    
    
    var querry: String = "" {
        didSet {
            searchCompleter.queryFragment = querry
        }
    }
    
    // cache the result
    var cachedRoute: MKRoute?
   

    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = searchCompleter.results
    }
    
    var userLocation: CLLocationCoordinate2D?
    var mapView: MKMapView?  // Add MKMapView property

    // Initialize with optional MKMapView
    init(mapView: MKMapView? = nil) {
          super.init()
          self.mapView = mapView
          searchCompleter.delegate = self
      }
    
    func calculateTripAmount(for carType: CarSelection) -> Double {
        guard let destinationCoordinate = selectedTripLocation?.coordinate else { return 0.0 }
        guard let userCoordinate = userLocation else { return 0.0 }
        
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let destinationLocation = CLLocation(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude)
        let distanceInMeters = userLocation.distance(from: destinationLocation)
        print("Distance in meters \(distanceInMeters)")
        return carType.calculatePriceInMeters(meters: distanceInMeters)
    }
    
    
    func clearCachedRoute() {
        self.cachedRoute = nil
    }

     
    func getPickupAndDropoffTime(with ETA: Double) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        pickupTime = dateFormatter.string(from: Date())
        dropoffTime = dateFormatter.string(from: Date() + ETA)
    }
    
    func getTripRoute(
        from userLocation: CLLocationCoordinate2D,
        to destinationLocation: CLLocationCoordinate2D,
        completion: @escaping (
            MKRoute
        ) -> Void
    ) {
        let userPlaceMark = MKPlacemark(coordinate: userLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: userPlaceMark)
        request.destination = MKMapItem(placemark: destinationPlaceMark)
        let direction = MKDirections(request: request)
        
        direction.calculate { response, error in
            if let err = error {
                print("Error getting directions \(err.localizedDescription)")
                return
            }
            
            guard let route = response?.routes.first else {
                print("No route found")
                return
            }
            print("Route fetched successfuly")
            self.getPickupAndDropoffTime(with: route.expectedTravelTime)
            completion(route)
        }
    }

    
    // MARK: Draw the route to the passenger from the drivers location
    func drawRouteToPassenger(
        from driverLocation: CLLocationCoordinate2D,
        completion: @escaping (MKRoute) -> Void
    ) {
        // check if its in the cache before we call again
        if let cachedRoute = cachedRoute {
            print("Using cached route")
            completion(cachedRoute)
            return
        }
        
        // if not in the cache fetch it
            Task {
                await DatabaseManager.shared.fetchPassengerCoordinates { passengerCoordinates in
                    guard let passengerCoordinates else { return }
                    
                    let driverPlacemark = MKPlacemark(coordinate: driverLocation)
                    let passengerPlacemark = MKPlacemark(coordinate: passengerCoordinates)
                    
                    let request = MKDirections.Request()
                    request.source = MKMapItem(placemark: driverPlacemark)
                    request.destination = MKMapItem(placemark: passengerPlacemark)
                    request.transportType = .automobile
                    
                    let directions = MKDirections(request: request)
                    directions.calculate { response, error in
                        if let err = error {
                            print("Error calculating directions \(err.localizedDescription)")
                            return
                        }
                        
                        guard let route = response?.routes.first else { return }
                        self.getPickupAndDropoffTime(with: route.expectedTravelTime)
                        
                        // cache the fetched route
                        self.cachedRoute = route
                        completion(route)
                        
//                        let driverAnnotation = MKPointAnnotation()
//                        driverAnnotation.coordinate = driverLocation
//                        driverAnnotation.title = "Driver"
//                        
//                        let passengerAnnotation = MKPointAnnotation()
//                        passengerAnnotation.coordinate = passengerCoordinates
//                        passengerAnnotation.title = "User"
//                        
//                        self.mapView?.addAnnotations([driverAnnotation, passengerAnnotation])
                    }
                }
            }
    }

    
    // MARK: -Helper
    func selectLocation(_ locationSearch: MKLocalSearchCompletion) {
        getCoordinates(forSearchCompletion: locationSearch) { response, error in
            if let err = error {
                print("Error getting location coordinates \(err.localizedDescription)")
                return
            }
            guard let item = response?.mapItems.first else { return }
            let coordinate = item.placemark.coordinate
            print("Coordinates: \(coordinate)")
            self.selectedTripLocation = TripLocation(title: locationSearch.title, coordinate: coordinate)
        }
    }
    
    // MARK: - convert completion to coordinates that will then be passed to the map
    func getCoordinates( forSearchCompletion localSearch: MKLocalSearchCompletion, completion: @escaping MKLocalSearch.CompletionHandler) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = localSearch.title.appending(localSearch.subtitle)
        let search = MKLocalSearch(request: searchRequest)
        search.start(completionHandler: completion)
    }
    
}
