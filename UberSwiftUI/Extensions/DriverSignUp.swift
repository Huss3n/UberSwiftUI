//
//  DriverSignUp.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 16/09/2024.
//

import SwiftUI

struct DriverSignUp: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: "xmark")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    dismiss()
                }
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Make Money")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                
                Text("Driving, John Doe")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
            }
            
            Text("We just need a few things from you")
                .foregroundStyle(.gray)
        
            Image("driver")
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
            
            HStack(spacing: 20) {
                Image(systemName: "person.crop.circle.badge.plus.fill")
                    .font(.title)
                
                VStack(alignment: .leading) {
                    Text("Get started")
                    Text("Profile Photo")
                        .font(.headline)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title2)
            }
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(10)
            
            
            HStack(spacing: 20) {
                Image(systemName: "car.fill")
                    .font(.title)
                
                VStack(alignment: .leading) {
                    Text("Get started")
                    Text("Add your vehicle")
                        .font(.headline)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
            }
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(10)
            
            Spacer()
            
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

#Preview {
    DriverSignUp()
}
