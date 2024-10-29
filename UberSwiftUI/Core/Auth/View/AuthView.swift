//
//  AuthView.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 10/09/2024.
//

import SwiftUI

struct AuthView: View {
    @StateObject private var authVM = AuthVM()
//    @StateObject var locationSearchVM = LocationSearchVM()

    
    @Environment(\.dismiss) var dismiss
    @State private var selectedCountry: String = "🇰🇪 Kenya"
    @State private var countryCode: String = "+254"
    @State private var successfulAuth: Bool = false
    @State private var verificationCodeSent: Bool = false
    @FocusState var numberpadIsFocused: Bool
    
    let countries = Countries().countries
    let countryCodes: [String: String] = [
          "🇰🇪 Kenya": "+254",
          "🇳🇬 Nigeria": "+234",
          "🇿🇦 South Africa": "+27",
          "🇪🇬 Egypt": "+20",
          "🇬🇭 Ghana": "+233",
          "🇹🇿 Tanzania": "+255",
          "🇺🇬 Uganda": "+256",
          "🇪🇹 Ethiopia": "+251",
          "🇲🇦 Morocco": "+212",
          "🇸🇳 Senegal": "+221"
      ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Enter your mobile number")
                    .font(.title3)
                    .padding(.bottom, 20)
                
                HStack(spacing: 0) {
                    Picker("", selection: $selectedCountry) {
                        ForEach(countries, id: \.self) { country in
                            Text(country)
                                .font(.headline)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal)
                    .onChange(of: selectedCountry) { newCountry in
                        countryCode = countryCodes[newCountry] ?? "+254"
                    }
                    HStack {
                        TextField("Phone number", text: $authVM.phoneNumber)
                            .keyboardType(.phonePad)
                            .focused($numberpadIsFocused)
                        Image(systemName: "person.badge.key.fill")
                    }
                    .padding(10)
                    .padding(.trailing, 4)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                }
                .padding(.leading, -25)
                
                Button(action: {
                    Task {
                        numberpadIsFocused = false
                        let formattedPhoneNumber = countryCode + authVM.phoneNumber
                        await authVM.verifyPhoneNumber(fullPhoneNumber: formattedPhoneNumber) { res in
                            if res {
                                print("Success sending code completion is \(res.description)")
                                verificationCodeSent = true
                            } else {
                                print("Failed sending code completion is \(res.description)")
                                verificationCodeSent = false
                            }
                        }
                    }
                }, label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(.black.opacity(0.9))
                        .cornerRadius(10)
                })
            
                Or
            
                VStack(spacing: 10) {
                    continueWith(systemImage: "apple.logo", name: "Apple")
                    continueWith(systemImage: "", name: "Google", imageName: "google")
                    continueWith(systemImage: "envelope.fill", name: "Email")
                }
                
                Or
                
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Find my Account")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Text("By proceeding you consent to get calls, WhatsApp or SMS messages, including by automated means, from Uber and its affiliates to the number provided")
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.gray)
                    .fontWeight(.light)
                
                Spacer()

                Image(systemName: "arrow.left")
                    .font(.headline)
                    .padding()
                    .background(.gray.opacity(0.4))
                    .clipShape(Circle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        dismiss()
                    }
                
            }
            .padding()
            .fullScreenCover(isPresented: $verificationCodeSent) {
                VerificationCodeView(authVM: authVM, successfulAuth: $successfulAuth)
            }
            .navigationDestination(isPresented: $successfulAuth) {
                Home()
                    .navigationBarBackButtonHidden()
//                    .environmentObject(locationSearchVM)
            }
        }
      
    }
    
    private func continueWith(systemImage: String, name: String, imageName: String? = nil) -> some View {
        HStack {
            if imageName != nil {
                Image(imageName ?? "")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 20)
            } else {
                Image(systemName: systemImage)
            }

            Text("Continue with \(name)")
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.gray.opacity(0.3))
        .cornerRadius(10)
    }
    
    private var Or: some View {
        HStack {
            Rectangle()
                .fill(.gray.opacity(0.4))
                .frame(height: 2)
            Text("or")
                .font(.subheadline)
            Rectangle()
                .fill(.gray.opacity(0.4))
                .frame(height: 2)
        }
    }
}

#Preview {
    AuthView()
}

struct Countries {
    let countries: [String] = [
        "🇰🇪 Kenya",
        "🇳🇬 Nigeria",
        "🇿🇦 South Africa",
        "🇪🇬 Egypt",
        "🇬🇭 Ghana",
        "🇹🇿 Tanzania",
        "🇺🇬 Uganda",
        "🇪🇹 Ethiopia",
        "🇲🇦 Morocco",
        "🇸🇳 Senegal"
    ]
}
