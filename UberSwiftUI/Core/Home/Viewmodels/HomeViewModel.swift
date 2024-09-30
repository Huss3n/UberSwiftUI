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

final class HomeViewModel: ObservableObject {
    @Published var userModel: UserModel?  = nil
    @Published var showPassengerPickUp: Bool = false
    
    
    init() {
        Task {
            await fetchUserData()
            startListeningForIsRideSent()
        }
    }
    
    func fetchIsRideSent() async {
        do {
            guard let driverUID = userModel?.userID else { return }
            let db = Firestore.firestore()
            let docSnapshot = try await db.collection("users").document(driverUID).getDocument()
            guard let data = docSnapshot.data() else { return }
            guard let isRideSent = data["isRideSent"] as? Bool else { return }
            print("isRide sent value : \(isRideSent)")
            DispatchQueue.main.async {
                self.showPassengerPickUp = isRideSent
            }
            
        } catch {
            print("Error getting ride sent value")
        }
    }
    
    
    func fetchUserData() async {
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
    
    // Check if a ride request has been sent
     func checkIsRideSent(for driverID: String) async throws {
         let docRef = Firestore.firestore().collection("users").document(driverID)
         let snapshot = try await docRef.getDocument()
         
         guard let data = snapshot.data(),
               let isRideSent = data["isRideSent"] as? Bool else { return }
         
         // If a ride request is sent, trigger the passenger pick-up view
         await MainActor.run {
             self.showPassengerPickUp = isRideSent
         }
     }
    
    // fetch the user who is requesting the ride details: - name and coordinates
    func fetchPassengerDetails(for passengerID: String, completion: @escaping (UserModel?) -> Void) async {
        do {
            let passengerDetails = try await DatabaseManager.shared.fetchUserFromDatabase(for: passengerID)
            completion(passengerDetails)
        } catch {
            completion(nil)
            print("Error fetching passenger details")
        }
        
    }
    
    func startListeningForIsRideSent() {
        guard let driverUID = userModel?.userID else { return }
        
        let docRef = Firestore.firestore().collection("users").document(driverUID)
        
        docRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let document = documentSnapshot, document.exists, let data = document.data() else {
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let isRideSent = data["isRideSent"] as? Bool {
                DispatchQueue.main.async {
                    self?.showPassengerPickUp = isRideSent
                }
            }
        }
    }



    
}
