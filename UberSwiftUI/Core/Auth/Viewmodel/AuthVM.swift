//
//  AuthVM.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 10/09/2024.
//

import Foundation

@MainActor
final class AuthVM: ObservableObject {
    let authManager = AuthManager.shared
    @Published var phoneNumber: String = ""
    @Published var verificationID: String?
    @Published var userModel: UserModel?
    
    var userID: String = ""
    
    func verifyPhoneNumber(fullPhoneNumber: String, completion: @escaping (Bool) -> Void) async {
          // Ensure the phone number is in E.164 format
          let formattedPhoneNumber = formatPhoneNumber(fullPhoneNumber)
          
          guard !formattedPhoneNumber.isEmpty else {
              print("Invalid phone number format")
              completion(false)
              return
          }
          
          do {
              verificationID = try await authManager.phoneNumberAuth(phoneNumber: formattedPhoneNumber)
              print("Successfully sent verification code")
              print(formattedPhoneNumber)
              completion(true)
          } catch let error as NSError {
              print("Error sending verification code: \(error), \(error.userInfo)")
              completion(false)
          }
      }
    
    // Verify the code entered by the user
    func verifyCode(_ verificationCode: String, completion: @escaping (Bool) -> Void) async throws {
        guard let verificationID = verificationID else {
            print("Verification ID is not set")
            completion(false)
            return
        }
        
        let authResult = try await authManager.signInWithVerificationCode(verificationID: verificationID, verificationCode: verificationCode)
        self.userID = authResult.user.uid
        
        guard let userLocation = LocationManager.shared.userLocation else { return }
        let userModel = UserModel(userID: userID, name: "Hussein Aisak", coordinates: userLocation, isDriver: false, isRideSent: false, isRideAccepted: false, routeToPassenger: ShouldClearMap.none, isCancelled: false)
//        let backendUserModel = BackendUserModel(userID: userID, name: "Hussein Aisak", coordinates: userLocation, isDriver: false, isRideSent: false)
        
        // MARK: - Not being used
        // call the backend to save user data
//        saveUserToBackend(backendUsermodel: backendUserModel) { success in
//            if success {
//                print("BACKEND DEBUG: User data saved successfully")
//            } else {
//                print("Failed to save user data")
//            }
//            print("User signed in: \(authResult.user.uid)")
//            completion(true)
//        }
        
      
//         Check if the user already exists in the database before saving
        do {
        
            let userExists = try await DatabaseManager.shared.doesUserExist(userID: userModel.userID)
            if !userExists {
                await DatabaseManager.shared.saveUserToDatabase(userModel: userModel)
            } else {
                print("User already exists, skipping save.")
            }
        } catch {
            print("Error checking if user exists: \(error.localizedDescription)")
        }
        print("User signed in: \(authResult.user.uid)")
        completion(true)
    }
    
    func fetchUser() async {
        do {
            let usermodel = try await DatabaseManager.shared.fetchUserFromDatabase(for: userID)
            print("usermodel from on apeear in auth vm \(usermodel)")
        } catch {
            print("Error fetching user data")
        }
    }
    
    // Save user data to the backend (Python)
    func saveUserToBackend(backendUsermodel: BackendUserModel, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "https://9ce4-41-139-206-153.ngrok-free.app/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "userID": backendUsermodel.userID,
            "name": backendUsermodel.name,
            "phoneNumber": phoneNumber,
            "coordinates": [
                "latitude": backendUsermodel.latitude,
                "longitude": backendUsermodel.longitude
            ],
            "isDriver": backendUsermodel.isDriver ?? false,
            "isRideSent": backendUsermodel.isRideSent ?? false
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("Failed to create request body")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending data to backend: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }.resume()
    }
    
    private func formatPhoneNumber(_ phoneNumber: String) -> String {
          // Remove any spaces or special characters
          let cleanedPhoneNumber = phoneNumber.filter { "0123456789".contains($0) }
          
          // Ensure the phone number starts with a "+"
          if cleanedPhoneNumber.hasPrefix("0") {
              let trimmedPhoneNumber = String(cleanedPhoneNumber.dropFirst())
              return "+254\(trimmedPhoneNumber)"
          } else if cleanedPhoneNumber.hasPrefix("254") {
              return "+\(cleanedPhoneNumber)"
          } else if cleanedPhoneNumber.hasPrefix("+254") {
              return cleanedPhoneNumber
          } else {
              return ""
          }
      }
}
