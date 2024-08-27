//
//  UberSwiftUIApp.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 24/08/2024.
//

import SwiftUI

@main
struct UberSwiftUIApp: App {
    @StateObject var locationSearchVM = LocationSearchVM()
    
    var body: some Scene {
        WindowGroup {
            Home()
                .environmentObject(locationSearchVM)
        }
    }
}
