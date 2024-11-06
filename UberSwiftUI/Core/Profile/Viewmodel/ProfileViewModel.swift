//
//  ProfileViewModel.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 16/09/2024.
//

import Foundation

final class ProfileViewModel: ObservableObject {
    @Published var userModel: UserModel?  = nil
    
    init() {
        Task {
            await fetchUserData()
        }
    }
    
    func fetchUserData() async {
        guard let uid = AuthManager.shared.getCurrentUserID() else { return }
        
        do {
            let usermodel = try await DatabaseManager.shared.fetchUserFromDatabase(for: uid)
            
            await MainActor.run {
                self.userModel = usermodel
                print("Project viewModel DEBUG: Usermodel \(userModel)")
            }
        } catch {
            print("Error fetcing user data \(error.localizedDescription)")
        }
    }
}


