//
//  RequestPop.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 27/08/2024.
//

import SwiftUI

struct RequestPop: View {
    @State var carSelection: CarSelection = .uberx
    @EnvironmentObject var locationSearchVM: LocationSearchVM
    
    var body: some View {
        VStack(spacing: 12) {
            
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(width: 30, height: 4)
                .padding(.vertical, 8)
            
            // MARK: Begin hstack
            HStack {
                VStack {
                    Circle()
                        .fill(.gray.opacity(0.6))
                        .frame(width: 10, height: 10)
                    
                    Rectangle()
                        .fill(.gray.opacity(0.7))
                        .frame(width: 1, height: 34)
                    
                    Rectangle()
                        .fill(.primary)
                        .frame(width: 10, height: 10)
                }
                
                // MARK: Location
                VStack(alignment: .leading, spacing: 38) {
                    Text("Current location")
                        .foregroundStyle(.gray)
                    
                    Text("Selected destination")
                }
                Spacer()
                
                // MARK: Time
                VStack(alignment: .leading, spacing: 38) {
                    Text("4:55pm")
                    Text("5.30pm")
                }
                .foregroundStyle(.gray)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .padding(.vertical, 10)
            
            Text("Suggested cars")
                .font(.headline)
                .foregroundStyle(Color(.systemGray))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // MARK: Begin hstack - suggested cars
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    CarType(
                        imageName: "uberx",
                        carSelected: .uberx,
                        price: locationSearchVM.calculateTripAmount(for: .uberx).toCurrency(),
                        backgroundColor: carSelection == .uberx ? .blue : Color(.systemGray5))
                        .onTapGesture { withAnimation(.bouncy) { carSelection = .uberx } }
                    
                    CarType(
                        imageName: "comfort",
                        carSelected: .uberComfort,
                        price: locationSearchVM.calculateTripAmount(for: .uberComfort).toCurrency(),
                        backgroundColor: carSelection == .uberComfort ? .blue : Color(.systemGray5))
                        .onTapGesture { withAnimation(.bouncy) { carSelection = .uberComfort} }
                    
                    CarType(
                        imageName: "green",
                        carSelected: .ubergreen,
                        price: locationSearchVM.calculateTripAmount(for: .ubergreen).toCurrency(),
                        backgroundColor: carSelection == .ubergreen ? .blue : Color(.systemGray5))
                        .onTapGesture { withAnimation(.bouncy) { carSelection = .ubergreen} }
                    
                }
            }
            .scrollIndicators(.hidden)
            
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
            .padding(.vertical, 4)
            .background(Color(.systemGray5))
            .cornerRadius(10)
            
            // MARK: Request ride
            Button(action: {
                
            }, label: {
                Text("Request \(carSelection.carName.uppercased())".uppercased())
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(Color(.systemBlue))
                    .cornerRadius(10)
            })
            
        }
        .padding(.horizontal)
        .padding(.bottom, 28)
        .background(.white)
        .clipShape(.rect(topLeadingRadius: 20, topTrailingRadius: 20))
    }
}


#Preview {
    RequestPop()
//    CarType(imageName: "comfort", carSelected: .uberComfort, backgroundColor: .red)
}


struct CarType: View {
    var imageName: String
    var carSelected: CarSelection
    var price: String
    var backgroundColor: Color

    
    var body: some View {
        VStack(alignment: .leading) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            Text(carSelected.carName)
            Text(price)
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
    
    var basePrice: Double {
        switch self {
        case .uberx: return 50
        case .uberComfort: return 100
        case .ubergreen: return 70
        }
    }
    
    func calculatePriceInMeters(meters: Double) -> Double {
        switch self {
        case .uberx: return (meters * 0.3) + basePrice
        case .uberComfort:  return (meters * 0.6) + basePrice
        case .ubergreen:  return (meters * 0.4) + basePrice
        }
    }
    
}