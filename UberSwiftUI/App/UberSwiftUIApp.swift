//
//  UberSwiftUIApp.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 24/08/2024.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
print("Firebase Configured")
    return true
  }
}

@main
struct UberSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var locationSearchVM = LocationSearchVM()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Home()
                    .environmentObject(locationSearchVM)
            }
        }
    }
}
