//
//  WebSocketManager.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 12/10/2024.
//

import Foundation
import Starscream
import Combine

class WebSocketManager: ObservableObject {
    private var socket: WebSocket!
    @Published var receivedMessage: String = ""

    init() {
        var request = URLRequest(url: URL(string: "")!) 
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }

    func joinRoom(room: String) {
        let joinEvent: [String: Any] = [
            "event": "join",
            "data": ["room": room]
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: joinEvent, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            socket.write(string: jsonString)
        }
    }

    func leaveRoom(room: String) {
        let leaveEvent: [String: Any] = [
            "event": "leave",
            "data": ["room": room]
        ]
        if let jsonData = try? JSONSerialization.data(withJSONObject: leaveEvent, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            socket.write(string: jsonString)
        }
    }
}

extension WebSocketManager: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("WebSocket connected: \(headers)")
        case .disconnected(let reason, let code):
            print("WebSocket disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
            DispatchQueue.main.async {
                self.receivedMessage = string
            }
            handleIncomingMessage(text: string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            print("WebSocket cancelled")
        case .error(let error):
            print("WebSocket error: \(error?.localizedDescription ?? "Unknown error")")
        case .peerClosed:
            break
        }
    }

    private func handleIncomingMessage(text: String) {
        // Parse the incoming JSON message
        guard let data = text.data(using: .utf8) else { return }
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let event = json["event"] as? String,
           let dataDict = json["data"] as? [String: Any] {
            switch event {
            case "new_ride":
                if let rideID = dataDict["ride_id"] as? String,
                   let passengerID = dataDict["passenger_id"] as? String {
                    print("New ride requested: \(rideID) by passenger \(passengerID)")
                }
            case "ride_accepted":
                if let rideID = dataDict["ride_id"] as? String,
                   let driverID = dataDict["driver_id"] as? String {
                    print("Ride \(rideID) accepted by driver \(driverID)")
                }
            default:
                break
            }
        }
    }
}
