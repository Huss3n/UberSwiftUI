//
//  PassengerPickup.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 16/09/2024.
//

import SwiftUI
import MapKit
import CoreLocation

final class PassengerPickupViewModel: ObservableObject {
    @Published var passengerData: UserModel?
    @Published var region: MKCoordinateRegion?
    
    init(passengerID: String) {
        Task {
            await fetchPassengerData(for: passengerID)
        }
    }
    
    private func fetchPassengerData(for passengerID: String) async {
        do {
            guard let passData = try await DatabaseManager.shared.fetchUserFromDatabase(for: passengerID) else { return }
            print("Passenger data is \(passData) as received in the passenger viewmodel")
            
            await MainActor.run {
                self.passengerData = passData
                
                // Update the region based on the passenger's location
                self.region = MKCoordinateRegion(
                    center: passData.coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        } catch {
            print("Error getting passenger data: \(error.localizedDescription)")
        }
    }
    
    
}

struct PassengerPickup: View {
    @StateObject private var viewModel: PassengerPickupViewModel
    
    init(passengerID: String) {
        _viewModel = StateObject(wrappedValue: PassengerPickupViewModel(passengerID: passengerID))
    }
    
    var body: some View {
        VStack {
            Capsule()
                .fill(Color.gray)
                .frame(width: 40, height: 6)
                .padding(.vertical)
            
            HStack(alignment: .top, spacing: 12) {
                Text("Would you like to pick up this passenger?")
                    .font(.headline)
                
                Spacer()
                
                VStack {
                    Text("10")
                    Text("Min")
                }
                .foregroundColor(.white)
                .font(.headline)
                .padding(10)
                .background(Color.blue)
                .cornerRadius(10)
            }
            
            Divider()
            
            VStack {
                HStack {
                    Image("forest")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.passengerData?.name ?? "Loading...")
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("4.9")
                                .foregroundColor(.gray)
                        }
                    }
                    .font(.subheadline)
                    
                    Spacer()
                    
                    VStack {
                        Text("Earnings")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Ksh 450")
                            .font(.subheadline)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Artcaffe, Kileleshwa")
                    Spacer()
                    Text("5.2 Km")
                }
                
                if let region = viewModel.region {
                    Map(coordinateRegion: .constant(region), annotationItems: [PickupLocation(coordinate: region.center)]) { location in
                        MapMarker(coordinate: location.coordinate, tint: .blue)
                    }
                    .frame(height: 140)
                    .cornerRadius(10)
                    .onAppear {
                        print("DEBUG: Map region center: \(region.center)")
                    }
                } else {
                    Text("Loading map...")
                        .frame(height: 140)
                        .cornerRadius(10)
                }
            }
            
            HStack(spacing: 60) {
                Button(action: {
                    // Handle reject action
                }) {
                    Text("REJECT")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 140, height: 45)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    // Handle accept action
                }) {
                    Text("ACCEPT")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 140, height: 45)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            print("DEBUG: PassengerPickup view appeared.")
        }
    }
}




struct PickupLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

