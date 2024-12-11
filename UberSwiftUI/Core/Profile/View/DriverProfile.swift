//
//  DriverProfile.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 16/09/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

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
    
    
    func cancelTrip() async {
        let db = Firestore.firestore()
        do {
            let docRef = db.collection("users").document("VbbNg4JpeBhiqYfmecER9PJRKan2")
            try await docRef.updateData(
                [
                    "isRideAccepted": false,
                    "routeToPassenger": ShouldClearMap.driver.stringValue,
                    "cancelledTrip": false
                ]
            )
        } catch {
            print("Error updating ride acceptance in cancel trip function: \(error.localizedDescription)")
        }
    }
}

struct DriverProfile: View {
    @StateObject private var viewModel: DriverViewModel
    
    @Binding var connectToDriver: Bool
    
    @State private var showCancelReason: Bool = false
    
    init(driverID: String, connectToDriver: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: DriverViewModel(driverID: driverID))
        self._connectToDriver = connectToDriver
    }
    
    var body: some View {
        VStack {
            
            Capsule()
                .fill(Color.gray)
                .frame(width: 40, height: 6)
                .padding(.vertical)
            
            
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading) {
                    Text("Meet your driver at 505,")
                        .font(.headline)
                    
                    Text("Kintyre Way")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                VStack {
                    Text("10")
                    Text("Min")
                }
                .foregroundColor(.white)
                .font(.headline)
                .padding(8)
                .background(Color.blue)
                .cornerRadius(7)
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
                showCancelReason.toggle()
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
        .sheet(isPresented: $showCancelReason) {
            CancelRideOptions(cancelFunc: {
                Task {
                    connectToDriver = false
                    await viewModel.cancelTrip()
                }
            })
            .presentationDetents([.fraction(0.7)])
        }
    }
}

#Preview {
    DriverProfile(driverID: "AbTIK4LfcOe21ho8e7XcMRupiH82", connectToDriver: .constant(true))
}
