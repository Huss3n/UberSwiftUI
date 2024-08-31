//
//  Settings.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 31/08/2024.
//

import SwiftUI

struct Settings: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {
                        header
                        SettingsRow(systemImage: "house.fill", title: "Add Home", showIcon: true)
                        SettingsRow(systemImage: "briefcase.fill", title: "Add Work", showIcon: true)
                        SettingsRow(systemImage: "mappin.circle.fill", title: "Shortcuts", subtitle: "Manage saved shortcuts", showIcon: true)
                        SettingsRow(systemImage: "lock.fill", title: "Privacy", subtitle: "Manage the data you share with us", showIcon: true)
                        SettingsRow(systemImage: "bell.fill", title: "Communication", subtitle: "Choose yout preffered contact methods and manage your notification settings", showIcon: true)
                        
                        SettingsRow(systemImage: "sun.max.fill", title: "Appearance", subtitle: "Light Mode", showIcon: true)
                        
                        Text("Safety")
                            .font(.title2.bold())
                        
                        SettingsRow(systemImage: "shield.righthalf.filled", title: "Safety preferences", subtitle: "Choose and schedule your favorite safety tools", showIcon: true)
                        SettingsRow(systemImage: "person.wave.2.fill", title: "Manage trusted contacts", subtitle: "Share your trip status with family and friends in a single tap", showIcon: true)
                        
                        SettingsRow(systemImage: "keyboard.chevron.compact.down.fill", title: "Verify your trip", subtitle: "Use a PIN to make sure you get in the right car", showIcon: true)
                        
                        SettingsRow(systemImage: "car.front.waves.down.fill", title: "RideCheck", subtitle: "Manage your RideCheck notifications", showIcon: true)
                        
                        Text("Ride Preferences")
                            .font(.title2.bold())
                        
                        SettingsRow(systemImage: "calendar.badge.plus", title: "Reserve", subtitle: "Choose how you're matched with drivers when you book ahead", showIcon: true)
                        
                        
                        Text("Sign out")
                            .font(.title3)
                            .foregroundStyle(.red)
                            .fontWeight(.semibold)
                    }
                    
                }
                .scrollIndicators(.hidden)
                
            }
            .padding(.horizontal)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "xmark")
                        .font(.title3.bold())
                        .onTapGesture {
                            showSettings.toggle()
                        }
                }
            }
        }
        
    }
}

#Preview {
    Settings(showSettings: .constant(true))
}



extension Settings {
    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "person.fill")
                .foregroundStyle(.gray.opacity(0.5))
                .font(.largeTitle)
                .padding(20)
                .background(Color(.systemGray6))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Hussein Aisak")
                    .font(.title3)
                    .fontWeight(.medium)
                
                Group {
                    Text("0712 000 000")
                    Text("aisackhussein@ gmail.com")
                }
                .fontWeight(.light)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.headline)
        }
        .padding(.vertical)
    }
}
