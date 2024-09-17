//
//  PassengerPickup.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 16/09/2024.
//

import SwiftUI
import MapKit
import CoreLocation

struct PassengerPickup: View {
    let passengerName: String
    let pickupLocation: PickupLocation
    
    // Create a state for the map region
    @State private var region: MKCoordinateRegion
    
    init(passengerName: String, pickupLocation: CLLocationCoordinate2D) {
        self.passengerName = passengerName
        self.pickupLocation = PickupLocation(coordinate: pickupLocation)
    
        _region = State(initialValue: MKCoordinateRegion(
            center: pickupLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        ))
    }
    
    
    var body: some View {
        VStack {
            Capsule()
                .fill(.gray)
                .frame(width: 40, height: 6)
                .padding(.vertical)
            
            HStack(alignment: .top, spacing: 24) {
                Text("Would you like to pick up this passenger?")
                    .font(.headline)
                
                Spacer()
                
                VStack {
                    Text("10")
                    Text("Min")
                }
                .foregroundStyle(.white)
                .font(.headline)
                .padding()
                .background(.blue)
                .cornerRadius(10)
            }
            
            Divider()
            
            HStack {
                Image("forest")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hussein Aisak")
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text("4.9")
                            .foregroundStyle(.gray)
                    }
                }
                .font(.headline)
                
                Spacer()
                
                VStack {
                    Text("Earnings")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    Text("Ksh 450")
                        .font(.headline)
                }
            }
            
            Divider()
            
            HStack {
                Text("Artcaffe, Kileleshwa")
                Spacer()
                Text("5.2 Km")
            }
            
            // Map showing the passenger's location
            Map(coordinateRegion: $region, annotationItems: [pickupLocation]) { location in
                MapMarker(coordinate: location.coordinate, tint: .blue)
            }
            .frame(height: 200)
            .cornerRadius(10)
            
            HStack(spacing: 60) {
                Button(action: {
                    
                }, label: {
                    Text("REJECT")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 140, height: 45)
                        .background(.red)
                        .cornerRadius(10)
                })
                // -1.280939661160636, 36.78184056740316
                Button(action: {
                    
                }, label: {
                    Text("ACCEPT")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 140, height: 45)
                        .background(.blue)
                        .cornerRadius(10)
                })
            }
        }
        .padding(.horizontal)
        .clipShape(.rect(topLeadingRadius: 20, topTrailingRadius: 20))
    }
}

#Preview {
    PassengerPickup(
         passengerName: "Hussein Aisak",
         pickupLocation: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
     )
}


struct PickupLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
