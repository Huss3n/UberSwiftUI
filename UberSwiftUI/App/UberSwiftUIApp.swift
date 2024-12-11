//
//  UberSwiftUIApp.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 24/08/2024.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseAuthCombineSwift

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("Firebase Configured")
        return true
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
            
            
        }
        completionHandler(.newData)
    }

    @available(iOS 10, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler()
            return
        }
        completionHandler()
    }
}


@main
struct UberSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    @StateObject var locationSearchVM = LocationSearchVM()
    
//    @AppStorage("selectedState") var selectedState: AppAppearance = .system
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Splash() 
//                Home()
//                    .preferredColorScheme(colorScheme)
//                    .environmentObject(locationSearchVM)
            }
        }
    }
    
//    private var colorScheme: ColorScheme? {
//         switch selectedState {
//         case .light: return .light
//         case .dark: return .dark
//         case .system: return nil
//         }
//     }
}
