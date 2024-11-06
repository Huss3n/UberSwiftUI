//
//  Profile.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 31/08/2024.
//

import SwiftUI

struct Profile: View {
    @ObservedObject var profileVM: HomeViewModel
    @State var showSettings: Bool = false
    @State var showMessages: Bool = false
    @State var showSafari: Bool = false
    @State var showManageAccount: Bool = false
    @State var showWallet: Bool = false
    @State var driverSignUp: Bool = false
    
    @State private var driverStatus: Bool = true
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                header
                rectangle
                
                // MARK: show the driver status here if the user is a driver
                if profileVM.userModel?.isDriver ?? false {
                    Text("UBER DRIVER")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack(spacing: 12) {
                        Image(systemName: "car.fill")
                            .font(.title)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(driverStatus ? "Online" : "Offline")
                                .font(.headline)
                            Text("Set your status to active to be able to receive ride requests")
                                .font(.subheadline)
                                .foregroundStyle(Color(.systemGray))
                        }
                        
                        Toggle(isOn: $driverStatus, label: {
                            Text("Label")
                        })
                        .labelsHidden()
                    }
                }
                
                
                // MARK: passenger
                ScrollView {
                    HStack(spacing: 20) {
                        rowWidget(systemImage: "questionmark.circle.fill", widgetName: "Help")
                        rowWidget(systemImage: "wallet.pass.fill", widgetName: "Wallet")
                            .onTapGesture {
                                showWallet.toggle()
                            }
                        rowWidget(systemImage: "newspaper.fill", widgetName: "Activity")
                    }
                    .padding(.vertical)
                    
                    
                    
                    uberChecks
                    rectangle
                    
                    // settings
                    VStack(alignment: .leading, spacing: 34) {
                        
                        SettingsRow(systemImage: "car.fill", title: "Make Money Driving")
                            .onTapGesture {
                                driverSignUp.toggle()
                            }
                        SettingsRow(systemImage: "person.3.fill", title: "Family", subtitle: "Manage a family profile")
                        SettingsRow(systemImage: "gear", title:  "Settings")
                            .onTapGesture { showSettings.toggle() }
                        
                        SettingsRow(systemImage: "envelope.fill", title: "Messages")
                            .onTapGesture { showMessages.toggle() }
                        
                        Button {
                            showSafari.toggle()
                        } label: {
                            SettingsRow(systemImage: "car.fill", title: "Earn by driving or delivering")
                        }
                        .tint(.primary)
                        .popover(isPresented: $showSafari) {
                            SafariViewWrapper(url: URL(string: "https://www.uber.com")!)
                        }
                        
                        Button {
                            showSafari.toggle()
                        } label: {
                            SettingsRow(systemImage: "briefcase.fill", title: "Setup your business profile", subtitle: "Automate work travel & meals")                        }
                        .tint(.primary)
                        .popover(isPresented: $showSafari) {
                            SafariViewWrapper(url: URL(string: "https://www.uber.com")!)
                        }
                        
                        
                        
                        Button {
                            showSafari = true
                        } label: {
                            SettingsRow(systemImage: "tag.fill", title: "Uber Eats promotions")          }
                        .tint(.primary)
                        .popover(isPresented: $showSafari) {
                            SafariViewWrapper(url: URL(string: "https://www.uber.com")!)
                        }
                        
                        SettingsRow(systemImage: "heart.fill", title: "Uber Eats Favorites")
                        SettingsRow(systemImage: "person.2", title: "Refer friends to get deals")
                        SettingsRow(systemImage: "person.fill", title: "Manage Uber Account")
                            .onTapGesture {
                                showManageAccount.toggle()
                            }
                        
                        Button {
                            showSafari = true
                        } label: {
                            SettingsRow(systemImage: "info.circle.fill", title: "Legal")                       }
                        .tint(.primary)
                        .popover(isPresented: $showSafari) {
                            SafariViewWrapper(url: URL(string: "https://www.uber.com/legal/en/")!)
                        }
                        
                        Text("v3.629.1000000")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    
                }
                .scrollIndicators(.hidden)
            }
            .refreshable {
                Task {
//                    await profileVM.fetchUserData()
                }
            }
            .onAppear {
                print("Driver status as of onappear is \(profileVM.userModel?.isDriver)")
            }
            .padding(.horizontal)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                            .tint(.primary)
                    })
                    .padding(.trailing, 8)
                }
            }
            .background(Color.appTheme.backgroundColor)
            .fullScreenCover(isPresented: $showSettings, content: {
                Settings(showSettings: $showSettings)
            })
            .fullScreenCover(isPresented: $showMessages, content: {
                Messages(showMessages: $showMessages)
            })
            .fullScreenCover(isPresented: $showManageAccount, content: {
                ManageProfile(showManageAccount: $showManageAccount)
            })
            .fullScreenCover(isPresented: $showWallet, content: {
                Wallet(showWallet: $showWallet)
            })
            .fullScreenCover(isPresented: $driverSignUp, content: {
                DriverSignUp()
            })
        }
    }
}

#Preview {
    Profile(profileVM: HomeViewModel())
}

extension Profile {
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                if let name = profileVM.userModel?.name {
                    Text(name)
                        .font(.title)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Image(systemName: "star.fill")
                    Text("4.9")
                }
                .padding(4)
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .cornerRadius(40)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            Image("forest")
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        }
    }
    
    private func rowWidget(systemImage: String, widgetName: String) -> some View {
        VStack(alignment: .center, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title)
            
            Text(widgetName)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(width: 110, height: 100)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private var rectangle: some View {
        Rectangle()
            .fill(.gray)
            .frame(height: 0.5)
            .padding(.vertical, 8)
            .padding(.bottom, 8)
    }
    
    private var uberChecks: some View {
        VStack(spacing: 14) {
            // promos
            HStack{
                VStack(alignment: .leading, spacing: 10) {
                    Text("You have multiple promos")
                        .font(.headline)
                    Text("We'll automatically apply them for you")
                        .font(.subheadline)
                        .fontWeight(.light)
                }
                
                Spacer()
                
                ZStack {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.pink)
                        .rotationEffect(Angle(degrees: -14))
                        .offset(y: 10)
                    
                    Image(systemName: "tag.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.purple)
                        .overlay {
                            Text("%")
                                .font(.title.bold())
                                .foregroundStyle(.white)
                        }
                }
                .padding(.top, 16)
                
            }
            .frame(width: 350, height: 120)
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // privacy checkup
            HStack{
                VStack(alignment: .leading, spacing: 10) {
                    Text("Privacy checkup")
                        .font(.headline)
                    Text("Take an interactive tour of your privacy settings.")
                        .font(.subheadline)
                        .fontWeight(.light)
                }
                
                Spacer()
                
                Image(systemName: "pencil.and.list.clipboard")
                    .font(.system(size: 60))
                    .foregroundStyle(Color(.systemBlue))
                    .rotationEffect(Angle(degrees: -14))
                    .offset(y: 10)
                    .padding(.top, 16)
                
                
            }
            .frame(width: 350, height: 100)
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // invite friends
            HStack{
                VStack(alignment: .leading, spacing: 10) {
                    Text("Invite friends to Uber")
                        .font(.headline)
                    Text("Each invite you will get KES 150 off 5 Uber rides.")
                        .font(.subheadline)
                        .fontWeight(.light)
                }
                
                Spacer()
                
                Image(systemName: "party.popper")
                    .font(.system(size: 60))
                    .foregroundStyle(Color(.systemGreen))
                    .rotationEffect(Angle(degrees: -45))
                    .offset(y: 10)
                
                
            }
            .frame(width: 350, height: 100)
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}
