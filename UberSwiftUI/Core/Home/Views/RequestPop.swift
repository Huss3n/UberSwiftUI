//
//  RequestPop.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 27/08/2024.
//

import SwiftUI

struct RequestPop: View {
    @State var carSelection: CarSelection = .uberx
    
    var body: some View {
        VStack(spacing: 24) {
            // MARK: Begin hstack
            HStack {
                VStack {
                    Circle()
                        .fill(.gray.opacity(0.6))
                        .frame(width: 6, height: 6)
                    
                    Rectangle()
                        .fill(.gray.opacity(0.7))
                        .frame(width: 1, height: 24)
                    
                    Rectangle()
                        .fill(.primary)
                        .frame(width: 6, height: 6)
                }
                
                // MARK: Location
                VStack(alignment: .leading, spacing: 20) {
                    Text("Current location")
                        .foregroundStyle(.gray)
                    
                    Text("Selected destination")
                }
                
                Spacer()
                
                // MARK: Time
                /// MARK: Begin hstack
                VStack(alignment: .leading, spacing: 20) {
                    Text("4:55pm")
                    Text("5.30pm")
                }
                .foregroundStyle(.gray)
                
            }
            /// MARK: End hstack
            
            Divider()
                .padding(.vertical, 10)
            
            Text("Suggested cars")
                .font(.headline)
                .foregroundStyle(Color(.systemGray))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            /// MARK: Begin hstack - suggested cars
            HStack(spacing: 10) {
                CarType(
                    imageName: "uberx",
                    carSelected: .uberx,
                    price: 500,
                    backgroundColor: carSelection == .uberx ? .blue : Color(.systemGray5))
                    .onTapGesture { carSelection = .uberx }
                
                CarType(
                    imageName: "comfort",
                    carSelected: .uberComfort,
                    price: 700,
                    backgroundColor: carSelection == .uberComfort ? .blue : Color(.systemGray5))
                    .onTapGesture { carSelection = .uberComfort }
                
                CarType(
                    imageName: "green",
                    carSelected: .ubergreen,
                    price: 900,
                    backgroundColor: carSelection == .ubergreen ? .blue : Color(.systemGray5))
                    .onTapGesture { carSelection = .ubergreen }
                
            }
            /// MARK: End hstack - suggested cars
            
            // MARK: Card
            HStack {
                Image("visa")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                
                Text("**** **** **** 1234")
                
                Spacer()
                
                Image(systemName: "chevron.right")
            }
            .font(.headline)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemGray5))
            .cornerRadius(10)
            
            
            // MARK: Request ride
            Button(action: {
                
            }, label: {
                Text("Request ride".uppercased())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color(.systemBlue))
                    .cornerRadius(10)
            })
            
            Spacer()
            
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
}

#Preview {
    RequestPop()
//    CarType(imageName: "comfort", carSelected: .uberComfort, backgroundColor: .red)
}


struct CarType: View {
    var imageName: String
    var carSelected: CarSelection
    var price: Int
    var backgroundColor: Color

    
    var body: some View {
        VStack(alignment: .leading) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            Text(carSelected.carName)
            Text("Ksh \(price)")
        }
        .font(.subheadline)
        .fontWeight(.medium)
        .frame(width: 120, height: 120)
        .background(backgroundColor)
        .cornerRadius(13)
    }
}


enum CarSelection {
    case uberx
    case uberComfort
    case ubergreen
    
    var carName: String {
        switch self {
        case .uberx:
            return "X"
        case .uberComfort:
            return "Comfort"
        case .ubergreen:
            return "Green"
        }
    }
    
}
