//
//  BackendRideService.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 12/10/2024.
//

import Foundation
import CoreLocation




class BackendRideService: ObservableObject {
    @Published var rides: [BackendRideModel] = []
    
    func requestRide(passengerID: String, pickupLocation: String, destinationLocation: String, completion: @escaping (Bool, String?) -> Void) {
          let url = BackendConfig.requestRideURL
          var request = URLRequest(url: url)
          request.httpMethod = "POST"
          request.setValue("application/json", forHTTPHeaderField: "Content-Type")
          
          let body: [String: Any] = [
              "passenger_id": passengerID,
              "pickup_location": pickupLocation,
              "destination_location": destinationLocation
          ]
          
          request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

          // Retrieve JWT token from Keychain
          if let tokenData = KeychainHelper.shared.read(service: "jwt", account: "userToken"),
             let token = String(data: tokenData, encoding: .utf8) {
              request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
          }

          URLSession.shared.dataTask(with: request) { data, response, error in
              // Handle errors or empty data
              guard let data = data, error == nil else {
                  completion(false, error?.localizedDescription)
                  return
              }

              // Attempt to decode the response data into a RideResponse object
              if let responseData = try? JSONDecoder().decode(RideResponse.self, from: data) {
                  DispatchQueue.main.async {
                      // Add the ride to the list of rides and call the completion handler
                      self.rides.append(BackendRideModel(
                          id: responseData.ride_id,
                          passenger_id: passengerID,
                          pickup_location: pickupLocation,
                          destination_location: destinationLocation,
                          status: "pending",
                          created_at: nil,
                          driver_id: nil
                      ))
                      completion(true, nil)
                  }
              } else {
                  // Handle decoding failure
                  let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                  completion(false, errorMessage)
              }
          }.resume() // Ensures the task is started
      }
    
    
    func acceptRide(rideID: String, driverID: String, completion: @escaping (Bool, String?) -> Void) {
        let url = BackendConfig.acceptRideURL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "ride_id": rideID,
            "driver_id": driverID
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        // Retrieve JWT token from Keychain
        if let tokenData = KeychainHelper.shared.read(service: "jwt", account: "userToken"),
           let token = String(data: tokenData, encoding: .utf8) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false, error?.localizedDescription)
                return
            }
            
            if let responseData = try? JSONDecoder().decode(RideResponse.self, from: data) {
                DispatchQueue.main.async {
                    // Optionally update local ride list
                    if let index = self.rides.firstIndex(where: { $0.id == rideID }) {
                        self.rides[index].status = "accepted"
                        self.rides[index].driver_id = driverID
                    }
                    completion(true, nil)
                }
            } else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                completion(false, errorMessage)
            }
        }.resume()
    }
}

struct RideResponse: Codable {
    let ride_id: String
}

