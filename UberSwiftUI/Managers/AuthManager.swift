//
//  AuthManager.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 10/09/2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseAuthCombineSwift
import FirebaseFirestoreCombineSwift


final class AuthManager {
    static let shared = AuthManager()
    
    // phone number authentication
    func phoneNumberAuth(phoneNumber: String) async throws -> String {
       return try await PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber)
    }
    
    // Verify the code and sign in the user
    func signInWithVerificationCode(verificationID: String, verificationCode: String) async throws -> AuthDataResult {
          let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
          let authResult = try await Auth.auth().signIn(with: credential)
          return authResult
      }
    
    func getCurrentUserID() -> String? {
        Auth.auth().currentUser?.uid
    }
}
