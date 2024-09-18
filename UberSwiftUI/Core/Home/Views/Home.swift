//
//  Home.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 24/08/2024.
//

import SwiftUI
import CoreLocation

final class HomeViewModel: ObservableObject {
    @Published var userModel: UserModel?  = nil
    
    init() {
        Task {
            await fetchUserData()
        }
    }

    
    private func fetchUserData() async {
        guard let uid = AuthManager.shared.getCurrentUserID() else { return }
        
        do {
            let usermodel = try await DatabaseManager.shared.fetchUserFromDatabase(for: uid)
            
            await MainActor.run {
                self.userModel = usermodel
                print("Usermodel \(userModel)")
            }
        } catch {
            print("Error fetcing user data \(error.localizedDescription)")
        }
    }
    
    // fetch the user who is requesting the ride details: - name and coordinates
    func fetchPassengerDetails(for passengerID: String) -> UserModel {
        return UserModel(userID: "", name: "Hussein AISAK", coordinates: CLLocationCoordinate2D(latitude: 40.7127, longitude: -74.0059))
    }
    
}

struct Home: View {
    @StateObject var homeViewModel = HomeViewModel()
    @State var mapState: MapState = .noInput
    @EnvironmentObject var locationSearchVM: LocationSearchVM
    @State private var showProfileView: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            ZStack(alignment: .top) {
                UberMapView(mapState: $mapState)
                    .ignoresSafeArea()
                
                if let userIsDriver = homeViewModel.userModel?.isDriver {
                    let passenger = homeViewModel.fetchPassengerDetails(for: "123")
                    PassengerPickup(passengerName: passenger.name, pickupLocation: passenger.coordinates)
                    
                } else {
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
                }
                
                HumbugerButton(mapState: $mapState)
            }
            
            if mapState == .locationSelected {
                RequestPop(requestButtonPressed: {
                    // call the function to request the ride
                    // this function needs to send a request to the available drivers
                    // so the func needs to have the uid of the currently logged in user
                    // using this uid, we will fetch the coordinates of the this passenger on the drivers end
                    // then populate the map with the details of the passenger
                }) // here there is a button where the user can request a ride
                    .transition(.move(edge: .bottom))
                    .zIndex(1)  
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            print("View appeared, map state is: \(mapState)")
        }
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
    }
}

//
//#Preview {
//    Home()
//}
