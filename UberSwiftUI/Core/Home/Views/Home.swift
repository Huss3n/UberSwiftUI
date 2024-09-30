//
//  Home.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 24/08/2024.
//

import SwiftUI

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
                
                // Conditionally update the UberMapView only when shouldUpdateMap is true
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
                }
                
                HumbugerButton(mapState: $mapState)
            }
            
            if mapState == .locationSelected {
                RequestPop(connectToDriver: $connectToDriver, requestButtonPressed: { passengerModel, destinationLocation in
                    
                    print("Passenger model \(passengerModel)")
                    
                    // start loading
                    connectToDriver = true
                    self.passengerDetails = passengerModel
                    print("DEBUG: Received passenger details at request pop closuer in the home view as: \(String(describing: passengerDetails))")
                    
                    Task {
                        try await RideRequestManager.shared.createRideRequest(passenger: passengerModel, destinationLocation: destinationLocation) { rideRequestID in
                            guard let rideRequestUID = rideRequestID else { return }
                            
                            // listen for driver acceptance
                            RideRequestManager.shared.listenForDriverAcceptance(rideRequestID: rideRequestUID) { accepted, driver in
                                if accepted, let driver = driver {
                                    // stop the loading animation
                                    connectToDriver = false
                                    if let isDriver = homeViewModel.userModel?.isDriver {
                                        homeViewModel.showPassengerPickUp.toggle()
                                    }
                                }
                            }
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
            if mapState == .profile {
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
        .sheet(isPresented: $homeViewModel.showPassengerPickUp) {
            PassengerPickup(passengerID: "o0BaNGIsfwa6IVmHYwNKO0L7n362")
                .presentationDetents([.medium])
        }
    }
}

//
//#Preview {
//    Home()
//}
