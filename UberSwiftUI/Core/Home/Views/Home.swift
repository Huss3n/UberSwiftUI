//
//  Home.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 24/08/2024.
//

import SwiftUI
import Combine

struct Home: View {
    @StateObject var homeViewModel = HomeViewModel()
    @State var mapState: MapState = .noInput
    @EnvironmentObject var locationSearchVM: LocationSearchVM
    @State private var showProfileView: Bool = false
    
    @State private var driverDetails: UserModel?
    @State private var connectToDriver: Bool = false
    
    
    @State var uid: String?
    @State var passengerDetails: UserModel?
    
    //    @State var showPassengerPickUp: Bool = false
    @State private var rideRequestID: String?
    
    // This state will store whether the map should update or not
    @State private var shouldUpdateMap = false
    
    
    var ridereq = RideRequestManager.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            ZStack(alignment: .top) {
                
                UberMapView(mapState: $mapState)
                    .ignoresSafeArea()
                    .onAppear {
                        // Trigger map update only when a location is selected
                        shouldUpdateMap = mapState == .locationSelected
                    }
                
                
                if mapState == .searchingForLocation {
                    SearchView(mapState: $mapState)
                        
                } else if mapState == .noInput {
                    LocationSearchView()
                        .padding(.top, 64)
                        .onTapGesture {
                            withAnimation(.spring) {
                                mapState = .searchingForLocation
                            }
                        }
                        .opacity(homeViewModel.userModel?.isDriver ?? false ? 0 : 1)
                }
                
                
                HumbugerButton(mapState: $mapState, connectToDriver: $connectToDriver)
            }
            
            if mapState == .locationSelected {
                RequestPop(connectToDriver: $connectToDriver, requestButtonPressed: { passengerModel, destinationLocation in
                    // Start loading
                    connectToDriver = true
                    self.passengerDetails = passengerModel
                    print("DEBUG: connectToDriver is now \(connectToDriver)")
                    print("DEBUG: Received passenger details at request pop closure in the home view as: \(String(describing: passengerDetails))")
                    
                    Task {
                        try await RideRequestManager.shared.createRideRequest(passenger: passengerModel, destinationLocation: destinationLocation) { rideRequestID in
                            guard let rideRequestUID = rideRequestID else { return }
                            self.rideRequestID = rideRequestUID
                            print("DEBUG: Ride request created with ID: \(rideRequestUID)")
                        }
                    }
                })
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onReceive(LocationManager.shared.$userLocation, perform: { location in
            locationSearchVM.userLocation = location
        })
        .onChange(of: mapState) {
            if mapState == .noInput {
                connectToDriver = false
            } else if mapState == .profile {
                showProfileView.toggle()
            }
        }
        .navigationDestination(isPresented: $showProfileView, destination: {
            Profile(profileVM: homeViewModel)
                .navigationBarBackButtonHidden()
                .onDisappear {
                    mapState = .noInput
                }
        })
        .sheet(
            isPresented: Binding(
                get: { homeViewModel.showPassengerPickUp && homeViewModel.isDriver },
                set: { homeViewModel.showPassengerPickUp = $0 }
            )
        ) {
            // ydN7t8p9VgPiHvDYf5XCRmLda773
            PassengerPickup(passengerID: "84vZFDN0jDOS4nUUzO7EriK8fmT2")
                .presentationDetents([.medium])
                .onAppear {
                    print("Passenger pick up appeared")
                }
        }
        .sheet(
            isPresented: Binding(
                get: { homeViewModel.showDriverDetails && !homeViewModel.isDriver },
                set: { homeViewModel.showDriverDetails = $0 }
            )
        ) {
            // o0BaNGIsfwa6IVmHYwNKO0L7n362
            DriverProfile(driverID: "VbbNg4JpeBhiqYfmecER9PJRKan2", connectToDriver: $connectToDriver)
                .presentationDetents([.fraction(0.35)])
        }
        .onChange(of: homeViewModel.rideStatus) { newStatus in
            if newStatus == .accepted {
                print("Driver is assigned")
                driverDetails = homeViewModel.driverDetails // Show driver details
                // Post a notification to inform the Home view
                NotificationCenter.default.post(name: Notification.Name("RideAccepted"), object: nil)
                
            } else if newStatus == .rejected {
                // Handle rejection, reset UI or show a message
                mapState = .noInput
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: Notification.Name("RideAccepted"), object: nil, queue: .main) { _ in
                // Handle the ride acceptance event
                mapState = .noInput // Dismiss the sheet by setting the state back to `noInput`
            }
        }
    }
}

//
//#Preview {
//    Home()
//}



extension Home {
    
}
