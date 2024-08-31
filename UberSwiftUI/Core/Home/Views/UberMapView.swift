//
//  UberMapView.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 24/08/2024.
//

import SwiftUI
import MapKit

struct UberMapView: UIViewRepresentable {
    let mapView = MKMapView()
    let locationManager = LocationManager.shared
    @Binding var mapState: MapState
    @EnvironmentObject var locationSearchVM: LocationSearchVM
   
   
    // makes the map view
    func makeUIView(context: Context) -> some UIView {
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        switch mapState {
        case .noInput:
            context.coordinator.clearRoutesAndRecenteruser()
            break
        case .locationSelected:
            break
        case .searchingForLocation:
            if let coordinate = locationSearchVM.selectedTripLocation {
                print("Coordinate is available in update UI \(coordinate)")
                print("DEBUG: Called everytime")
                context.coordinator.addAndSelectAnnotation(withCoordinate: coordinate.coordinate)
                context.coordinator.drawRouteToDestination(to: coordinate.coordinate)
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
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        let polyline = MKPolylineRenderer(overlay: overlay)
        polyline.strokeColor = .blue
        polyline.lineWidth = 6
        return polyline
    }
    
    


}
