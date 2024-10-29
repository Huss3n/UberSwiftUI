//
//  UberMapView.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 24/08/2024.
//

import SwiftUI
import MapKit
import Combine

struct UberMapView: UIViewRepresentable {
    let mapView = MKMapView()
    let locationManager = LocationManager.shared
    @Binding var mapState: MapState
    @EnvironmentObject var locationSearchVM: LocationSearchVM
    
    let driverID: String = "VbbNg4JpeBhiqYfmecER9PJRKan2"
    
    
    var cancellables = Set<AnyCancellable>()
    
    
    func isDriver() -> Bool {
        guard let userID = AuthManager.shared.getCurrentUserID() else { return false }
        print("Value of the userID is \(userID)")
        return userID == driverID
    }
    
    
    // makes the map view
    func makeUIView(context: Context) -> some UIView {
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        // pass the MKMapView instance to the LocationSearchVM
        locationSearchVM.mapView = mapView
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if isDriver() {
            // Check if routeToPassenger is available
            guard let value = DatabaseManager.shared.routeToPassenger else { return }
            print("Value of route to passenger is \(value)")

            if value == .passenger {
                // If true, draw the route if it's not already drawn
                if !context.coordinator.isRouteDrawn {
                    updateDriverMap(context: context)
                }
            } else if value == .driver {
                // If false, clear the map route to passenger
                context.coordinator.clearRouteToPassenger()
            }
        } else {
            updateUserMap(context: context)
        }
    }

    
    func updateDriverMap(context: Context) {
        // Handle map behavior for the driver (e.g., showing route to the passenger)
        print("DEBUG: Showing map for the driver")
        context.coordinator.drawRouteFromDriverToPassenger()
    }
    
    func updateUserMap(context: Context) {
        // Handle map behavior for the user (e.g., showing route to the destination)
        print("DEBUG: Showing map for the user")
        switch mapState {
        case .noInput:
            context.coordinator.clearRoutesAndRecenteruser()
        case .locationSelected:
            break
        case .searchingForLocation:
            if let destinationCoordinate = locationSearchVM.selectedTripLocation {
                print("Coordinate available in update UI \(destinationCoordinate.coordinate)")
                print("DEBUG: Called for user")
                context.coordinator.addAndSelectAnnotation(withCoordinate: destinationCoordinate.coordinate)
                context.coordinator.drawRouteToDestination(to: destinationCoordinate.coordinate)
            }
        case .profile:
            break
        }
    }
    
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self)
    }
    
}


extension MapCoordinator {
    
    func clearRoutesAndRecenteruser() {
        // remove overlay
        parent.mapView.removeOverlays(parent.mapView.overlays)
        
        // remove annotations
        parent.mapView.removeAnnotations(parent.mapView.annotations)
        
        // recenter the map region to the user
        if let region = region {
            parent.mapView.setRegion(region, animated: true)
        }
    }
}


class MapCoordinator: NSObject, MKMapViewDelegate {
    let parent: UberMapView
    
    var userLocation: CLLocationCoordinate2D?
    
    var region: MKCoordinateRegion?
    
    
    // check whether the route is drawn
    var isRouteDrawn: Bool = false
    
    init(parent: UberMapView) {
        self.parent = parent
        super.init()
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        self.userLocation = userLocation.coordinate
        
        let coordinate = userLocation.coordinate
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.005,
                longitudeDelta: 0.005
            )
        )
        self.region = region
        parent.mapView.setRegion(region, animated: true)
    }
    
    
    func addAndSelectAnnotation(withCoordinate coordinate: CLLocationCoordinate2D) {
        parent.mapView.removeAnnotations(parent.mapView.annotations)
        let anno = MKPointAnnotation()
        anno.coordinate = coordinate
        print("Coordinate in the map coordinator \(anno.coordinate)")
        parent.mapView.addAnnotation(anno)
        parent.mapView.selectAnnotation(anno, animated: true)
    }
    
    func drawRouteToDestination(to destinationCoordinate: CLLocationCoordinate2D) {
        guard let userloc = self.userLocation else {
            print("Could not get the users location")
            return
        }
        print("Successfuly received the users location: \(userloc)")
        parent.locationSearchVM.getTripRoute(from: userloc, to: destinationCoordinate) { route in
            print("Route to be drawn is \(route)")
            self.parent.mapView.addOverlay(route.polyline)
            let rectangle = self.parent.mapView.mapRectThatFits(route.polyline.boundingMapRect, edgePadding: .init(top: 64, left: 32, bottom: 500, right: 32))
            self.parent.mapView.setRegion(MKCoordinateRegion(rectangle), animated: true)
        }
    }
    
    
    func drawRouteFromDriverToPassenger() {
        guard let driverLocation = self.userLocation else {
            print("Could not get the drivers location")
            return
        }
        print("Successfully received drivers location \(driverLocation)")
        parent.locationSearchVM.drawRouteToPassenger(from: driverLocation) { route in
            print("Passenger route to be drawn is \(route)")
            self.isRouteDrawn = true
            self.parent.mapView.addOverlay(route.polyline)
            let rectangle = self.parent.mapView.mapRectThatFits(route.polyline.boundingMapRect, edgePadding: .init(top: 74, left: 42, bottom: 600, right: 42))
            self.parent.mapView.setRegion(MKCoordinateRegion(rectangle), animated: true)
        }
    }
    
    func clearRouteToPassenger() {
        // Remove all overlays (this will clear the route)
        parent.mapView.removeOverlays(parent.mapView.overlays)
        
        // clear cached route
        parent.locationSearchVM.clearCachedRoute()

        // recenter the map
        if let region = self.region {
            parent.mapView.setRegion(region, animated: true)
        }

        // Reset route-drawn flag
        self.isRouteDrawn = false
    }

    
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        let polyline = MKPolylineRenderer(overlay: overlay)
        polyline.strokeColor = .blue
        polyline.lineWidth = 6
        print("Rendering polyline for route")
        return polyline
    }
}



enum ShouldClearMap {
    case none
    case passenger
    case driver
    
    var stringValue: String {
        switch self {
        case .none:
            return "None"
        case .passenger:
            return "Passenger"
        case .driver:
            return "Driver"
        }
    }
    
    // Initialize from a string
    init(from string: String) {
        switch string {
        case "Passenger":
            self = .passenger
        case "Driver":
            self = .driver
        default:
            self = .none
        }
    }
}

