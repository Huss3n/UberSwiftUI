//
//  DriverProfile.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 16/09/2024.
//

import SwiftUI


final class DriverViewModel: ObservableObject {
    @Published var driverData: UserModel?
    
    init(driverID: String) {
        Task {
            await fetchDriverData(for: driverID)
        }
    }
    
    private func fetchDriverData(for driverID: String) async {
        do {
            guard let driverData = try await DatabaseManager.shared.fetchUserFromDatabase(for: driverID) else { return }
            print("Driver data is \(driverData) as received in the driver viewmodel")
            
            await MainActor.run {
                self.driverData = driverData
            }
        } catch {
            print("Error getting driver data: \(error.localizedDescription)")
        }
    }
}

struct DriverProfile: View {
    @StateObject private var viewModel: DriverViewModel
    
    init(driverID: String) {
        _viewModel = StateObject(wrappedValue: DriverViewModel(driverID: driverID))
    }
    
    var body: some View {
        VStack {
            
            Capsule()
                .fill(Color.gray)
                .frame(width: 40, height: 6)
                .padding(.vertical)
            
            
            HStack(alignment: .top, spacing: 12) {
                Text("Meet your driver at Artcaffe, Kileleshwa")
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
            
            HStack {
                Image("mountain")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.driverData?.name ?? "Loading...")
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("4.9")
                            .foregroundColor(.gray)
                    }
                }
                .font(.subheadline)
                
                Spacer()
                
                VStack(spacing: 10) {
                    Image(systemName: "car")
                        .font(.title)
                        .foregroundStyle(.red)
                    
                    HStack {
                        Text("Toyota vitz")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        
                        Text("KDG 001G")
                            .font(.subheadline)
                            .fontWeight(.light)
                    }
                }
            }
            
            Button(action: {
                // Handle cancel action
            }) {
                Text("CANCEL TRIP")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            
        }
        .padding(.horizontal)
    }
}

#Preview {
    DriverProfile(driverID: "AbTIK4LfcOe21ho8e7XcMRupiH82")
}
