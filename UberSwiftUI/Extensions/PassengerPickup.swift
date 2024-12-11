//
//  PassengerPickup.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 16/09/2024.
//

import SwiftUI
import MapKit
import CoreLocation
import Firebase
import FirebaseFirestore

final class PassengerPickupViewModel: ObservableObject {
    @Published var passengerData: UserModel?
    @Published var region: MKCoordinateRegion?
    
    init(passengerID: String) {
        print("DEBUG: PassengerPickupViewModel initialized with passengerID: \(passengerID)")
          Task {
              await fetchPassengerData(for: passengerID)
          }
      }
    
    private func fetchPassengerData(for passengerID: String) async {
        print("DEBUG: Starting to fetch passenger data for ID: \(passengerID)")
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
            print("DEBUG: Updated UI with passenger data")
        } catch {
            print("Error getting passenger data: \(error.localizedDescription)")
        }
    }
    
    func fetchRideRequests() async {
        let db = Firestore.firestore()
        
        do {
            let docSnap = try await db.collection("rideRequest").document("VbbNg4JpeBhiqYfmecER9PJRKan2").getDocument()
            guard let data = docSnap.data() else { return }
            print("Data from ride requests: \(data)")
        } catch {
            print("Error fetching ride requests")
        }
    }
    
    func acceptRide() async {
        let db = Firestore.firestore()
        
        do {
            let driverRef = db.collection("users").document("VbbNg4JpeBhiqYfmecER9PJRKan2")
            try await driverRef.updateData([
                "isRideAccepted": true,
                "isRideSent": false,
                "routeToPassenger": ShouldClearMap.passenger.stringValue
            ])
            print("Successfully updated isRideSent to true for driver is ride accepted and false for ride sent")

        } catch {
            print("Error updating the document fields")
        }
    }
    
}

struct PassengerPickup: View {
    @StateObject private var viewModel: PassengerPickupViewModel
    @Environment(\.dismiss) private var dismiss

    
    init(passengerID: String) {
         print("DEBUG: Initializing PassengerPickup with passengerID: \(passengerID)")
         _viewModel = StateObject(wrappedValue: PassengerPickupViewModel(passengerID: passengerID))
     }
    
    var body: some View {
        
        Group {
            if viewModel.passengerData == nil {
                VStack {
                    ProgressView("Loading passenger data...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                
            } else {
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
                            Text("505, Kintyre Way")
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
                            print("accept button pressed")
                            Task {
                                await viewModel.acceptRide()
                                 NotificationCenter.default.post(name: Notification.Name("RideAccepted"), object: nil)
                             }
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
    }
}




struct PickupLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct DestinationLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

