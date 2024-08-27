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
    @Published var selectedLocationCoordinates:  CLLocationCoordinate2D?

    
    var querry: String = "" {
        didSet {
            searchCompleter.queryFragment = querry
        }
    }
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.queryFragment = querry
    }
    
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = searchCompleter.results
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
            self.selectedLocationCoordinates = coordinate
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
