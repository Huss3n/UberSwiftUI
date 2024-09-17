//
//  ManageProfile.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 31/08/2024.
//

import SwiftUI


struct ManageProfile: View {
    @State private var activeTab: HeaderFilterButtons = .accountInfo
    @State var showSafari: Bool = false
    @Binding var showManageAccount: Bool
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                HeaderFilter(selectedFilter: $activeTab)
                
                ScrollView {
                    VStack {
                        if activeTab == .accountInfo {
                            accountInfo
                        } else if activeTab == .security {
                            security
                        } else {
                            privacy
                        }
                        
                    }
                }
                .scrollIndicators(.hidden)
                
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Uber Account")
                        .font(.title)
                        .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .onTapGesture {
                            showManageAccount.toggle()
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ManageProfile(showManageAccount: .constant(true))
}


extension ManageProfile {
    
    private func basicInfoRow(title: String, subtitle: String, verified: Bool? = nil) -> some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(.headline)
                    HStack {
                        Text(subtitle)
                            .fontWeight(.light)
                        
                        if verified  ?? false {
                           Image(systemName: "checkmark")
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .padding(4)
                                .background(.green)
                                .clipShape(Circle())
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
            }
            
            Divider()
        }
    }
    
    private var accountInfo: some View {
        VStack(alignment: .leading) {
            Text("Account Info")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.vertical)
            
            Image(systemName: "person.fill")
                .foregroundStyle(.gray)
                .font(.largeTitle)
                .padding(30)
                .background(Color(.systemGray6))
                .clipShape(Circle())
            
            Text("Basic Info")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.vertical)
            
            VStack(spacing: 20) {
                basicInfoRow(title: "Name", subtitle: "Hussein Aisak")
                basicInfoRow(title: "Phone number", subtitle: "0712 000 000", verified: true)
                basicInfoRow(title: "Email", subtitle: "aisackhussein @gmail.com", verified: true)
            }
            .padding(.vertical)
        }
    }
    
    private var security: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Security")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("Logging in to Uber")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.headline)
                        Text("*********")
                            .font(.headline)
                        
                        Text("Last changed 30 August 2024")
                            .fontWeight(.light)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                }
                
                Divider()
            }
            
            securityRows(title: "Passkeys", description: "Passkeys are easier and more secure than passwords")
            securityRows(title: "Authenticator App", description: "Set up your authenticator app to add an extra layer of security")
            
            securityRows(title: "2-step verification", description: "Add additional security to your account with 2-step verification")
            
            Text("Connected social apps")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Once you've allowed social apps to sign in to your Uber account, you'll see them here.")
            
           Divider()
            
        }
    }
    
    private var privacy: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Privacy & data")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("Privacy")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.vertical)
            
            HStack {
                Button(action: {
                    showSafari.toggle()
                }, label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Privacy Centre")
                            .font(.headline)
                        Text("Take control of your privacy and learn how we protect it.")
                            .fontWeight(.light)
                            .multilineTextAlignment(.leading)
                    }
                })
                .tint(.primary)
                .popover(isPresented: $showSafari, content: {
                    SafariViewWrapper(url: URL(string: "https://privacy.uber.com/center")!)
                })
                 
                Spacer()
                
                Image(systemName: "chevron.right")
            }
            
            Text("Third-party apps with account access")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top)
                .padding(.vertical, 8)
            
            Group {
                Text("Once you allow access to third-party apps, you'll see them here.") +
                Text(" Learn more")
                    .underline(color: Color.primary)
            }
            .fontWeight(.light)
            
        }
    }
    
    private func securityRows(title: String, description: String) -> some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                    Text(description)
                        .fontWeight(.light)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
            }
            
            Divider()
        }
    }
}
