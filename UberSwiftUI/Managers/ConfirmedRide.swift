//
//  ConfirmedRide.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 17/09/2024.
//

import SwiftUI

struct ConfirmedRide: View {
    var body: some View {
        VStack {
            Capsule()
                .fill(.gray)
                .frame(width: 40, height: 6)
            
            HStack(alignment: .top, spacing: 40) {
                VStack(alignment: .leading) {
                    Text("Your driver is on the way")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    Text("Arriving in")
                    Text("10")
                    Text("Mins")
                }
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding(10)
                .background(.blue)
                .cornerRadius(10)
            }
            .padding(.vertical)
            
            Divider()
            
            
            HStack {
                Image("mountain")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .fontWeight(.bold)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(RideRequestManager.shared.driverModel?.name ?? "Jonh Doe")
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text("4.4")
                            .foregroundStyle(.gray)
                    }
                }
                .font(.headline)
                
                Spacer()
                
                VStack {
                    Image("sedan")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.red)
                        .frame(width: 60, height: 60)
                    
                    Text("Toyota Vitz, Red")
                        .foregroundStyle(.gray)
                        .font(.callout)
                    
                    Text("KDM 000J")
                        .foregroundStyle(.primary)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    
                }
            }
    
            
            Button {
                
            } label: {
                Text("Cancel Request")
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(.red)
                    .clipShape(Capsule())
            }

            
        }
        .padding(.horizontal)
        .clipShape(.rect(topLeadingRadius: 20, topTrailingRadius: 20))
    }
}

#Preview {
    ConfirmedRide()
}
