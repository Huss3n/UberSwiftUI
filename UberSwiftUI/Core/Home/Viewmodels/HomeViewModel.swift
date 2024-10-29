//
//  HomeViewModel.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 21/09/2024.
//

import Foundation
import CoreLocation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import Combine

final class HomeViewModel: ObservableObject {
    @Published var userModel: UserModel? = nil
    @Published var showPassengerPickUp: Bool = false
    @Published var rideStatus: RideState = .pending // Default state is 'pending'
    @Published var driverDetails: UserModel? // Store the driver's details after acceptance
    @Published var showDriverDetails: Bool = false
    @Published var isDriver: Bool = false // Determine this based on the user data

    private var rideRequestID: String?
    
    private var cancellables = Set<AnyCancellable>()
    private var isRunning: Bool = false
    var timer: Timer?
    
    private var listener: ListenerRegistration?
    
    
    init() {
        Task {
            await fetchUserData()
            startRideListener()
            startRideAcceptanceListener()
            DatabaseManager.shared.startListenerForRoutePassenger()
            DatabaseManager.shared.startListeningForCancelledTrip()
        }
    }
    
    func startRideListener() {
          
          let db = Firestore.firestore()
          listener = db.collection("users")
              .document("VbbNg4JpeBhiqYfmecER9PJRKan2")
              .addSnapshotListener { [weak self] documentSnapshot, error in
                  guard let document = documentSnapshot else {
                      print("Error fetching document: \(error?.localizedDescription ?? "Unknown")")
                      return
                  }
                  
                  let isRideSent = document.data()?["isRideSent"] as? Bool ?? false
                  
                  DispatchQueue.main.async {
                      if self?.showPassengerPickUp != isRideSent {
                          self?.showPassengerPickUp = isRideSent
                      }
                  }
              }
      }
      
    func stopRideListener() {
           listener?.remove()
           listener = nil
       }

    deinit {
          stopRideListener()
      }
    
    
    // add a listerner for the ride acceptance
    func startRideAcceptanceListener() {
        let db = Firestore.firestore()
        listener = db.collection("users")
            .document("VbbNg4JpeBhiqYfmecER9PJRKan2")
            .addSnapshotListener { [weak self] documentSnapshot, error in
                if let error = error {
                    print("Error fetching document: \(error.localizedDescription)")
                    return
                }
                
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error?.localizedDescription ?? "Unknown")")
                    return
                }
                
                let isRideAccepted = document.data()?["isRideAccepted"] as? Bool ?? false
                
                DispatchQueue.main.async {
                    if self?.showDriverDetails != isRideAccepted {
                        self?.showDriverDetails = isRideAccepted
                    }
                }
            }
    }
    
    
    func checkIsRideSentValue() async {
        print("DEBUG: Checking ride sent value") // This should print every 2 seconds if the timer is working correctly
        let db = Firestore.firestore()
        do {
            let docSnap = try await db.collection("users").document("VbbNg4JpeBhiqYfmecER9PJRKan2").getDocument()
            guard let data = docSnap.data() else {
                print("DEBUG: No data found in Firestore")
                return
            }
            let isRideSent = data["isRideSent"] as? Bool ?? false
            print("DEBUG: isRideSent value is \(isRideSent)") // This should print the value of isRideSent every time
            self.showPassengerPickUp = isRideSent
        } catch {
            print("DEBUG: Error getting the value data \(error.localizedDescription)")
        }
    }

    /*
    //    private func setupBindings() {
    //        RideRequestManager.shared.$showPassengerPickUp
    //            .receive(on: DispatchQueue.main)
    //            .sink { [weak self] newValue in
    //                print("DEBUG: HomeViewModel detected showPassengerPickUp change: \(newValue)")
    //                self?.showPassengerPickUp = newValue
    //            }
    //            .store(in: &cancellables)
    //
    //
    //        // Listen for ride acceptance notification
    //        NotificationCenter.default.addObserver(forName: Notification.Name("RideAccepted"), object: nil, queue: .main) { [weak self] _ in
    //            self?.rideStatus = .accepted
    //            self?.showPassengerPickUp = false // Hide passenger pickup
    //            // Show the driver details sheet or update any state variables needed
    //            self?.showDriverDetails = true
    //        }
    //    }
    */

    func fetchUserData() async {
        guard let uid = AuthManager.shared.getCurrentUserID() else { return }
        
        do {
            let usermodel = try await DatabaseManager.shared.fetchUserFromDatabase(for: uid)
            
            await MainActor.run {
                self.userModel = usermodel
                self.isDriver = usermodel?.isDriver ?? false // Set isDriver based on the fetched data

            }
        } catch {
            print("Error fetcing user data \(error.localizedDescription)")
        }
    }

    // Start listening for ride status changes
    func startListeningForRideStatus(rideRequestID: String) {
        self.rideRequestID = rideRequestID
        let docRef = Firestore.firestore().collection("rideRequests").document(rideRequestID)
        
        // Listen for real-time updates on the ride request document
        docRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let document = documentSnapshot, document.exists, let data = document.data() else {
                print("Error fetching ride request: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Check the status field in the document
            if let statusString = data["status"] as? String, let status = RideState(rawValue: statusString) {
                DispatchQueue.main.async {
                    self?.rideStatus = status
                    print("DEBUG: Ride status updated to: \(status)")
                    
                    // If the ride is accepted, fetch the driver's details
                    if status == .accepted, let driverID = data["driverID"] as? String {
                        self?.fetchDriverDetails(driverID: driverID)
                    }
                    
                    // Handle other status changes if needed (e.g., rejected)
                    if status == .rejected {
                        // Reset the UI or show a message to the user
                        print("DEBUG: Ride was rejected.")
                    }
                }
            }
        }
    }

    // Fetch the driver's details after acceptance
    private func fetchDriverDetails(driverID: String) {
        let docRef = Firestore.firestore().collection("users").document(driverID)
        docRef.getDocument { [weak self] (document, error) in
            guard let document = document, document.exists, let data = document.data() else {
                print("Error fetching driver details: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Extract fields from the document to create a UserModel instance
            if let name = data["name"] as? String,
               let coordinatesData = data["coordinates"] as? [String: Double],
               let latitude = coordinatesData["latitude"],
               let longitude = coordinatesData["longitude"] {
                
                let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let isDriver = data["isDriver"] as? Bool
                let isRideSent = data["isRideSent"] as? Bool
                let isRideAccepted = data["isRideAccepted"] as? Bool
                let routeToPassenger = data["routeToPassenger"] as? ShouldClearMap
                let cancelledTrip = data["cancalledTrip"] as? Bool

                let driver = UserModel(userID: driverID, name: name, coordinates: coordinates, isDriver: isDriver, isRideSent: isRideSent, isRideAccepted: isRideAccepted, routeToPassenger: routeToPassenger, isCancelled: cancelledTrip)
                
                // Update the view model's property
                DispatchQueue.main.async {
                    self?.driverDetails = driver
                }
            } else {
                print("Error: Unable to parse driver details.")
            }
        }
    }

}
