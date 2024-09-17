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
        let userModel = UserModel(userID: userID, name: "Hussein Aisak", coordinates: userLocation)
        await DatabaseManager.shared.saveUserToDatabase(userModel: userModel)
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
