//
//  CancelRideOptions.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 30/10/2024.
//

import SwiftUI

struct CancelRideOptions: View {
    
    var cancelFunc: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "arrow.left")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Cancel Ride?")
                    .font(.headline)
                
                Text("Skip")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .onTapGesture {
                        cancelFunc()
                    }
            }
            .padding(.top, 20)
            
            
            Rectangle()
                .frame(height: 0.3)
            
            Text("Why do you want to cancel?")
                .font(.headline)
            
            Text("Optional")
                .font(.subheadline)
            
            cancelOptions(imageName: "person.crop.circle.badge.xmark.fill", reason: "Could not find driver")
            cancelOptions(imageName: "person.badge.clock", reason: "Driver not gettinng closer")
            cancelOptions(imageName: "car.badge.gearshape.fill", reason: "Driver arrived early")
            cancelOptions(imageName: "person.crop.circle.badge.questionmark.fill.ar", reason: "Driver asked me to cancel or pay off app")
            cancelOptions(imageName: "hourglass.bottomhalf.filled", reason: "Wait time was too long")
            cancelOptions(imageName: "chevron.down.dotted.2", reason: "Other")
            
            
            Button {
                dismiss()
            } label: {
                Text("Keep my trip")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.black)
                    .cornerRadius(10)
            }
            
            Spacer()
            
        }
        .padding(.horizontal)
    }
    
    
    func cancelOptions(imageName: String, reason: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: imageName)
            
            VStack(alignment: .leading) {
                Text(reason)
                Rectangle()
                    .fill(.gray)
                    .frame(height: 0.5)
            }
        }
        .onTapGesture {
            cancelFunc()
        }
    }
    
}

#Preview {
    CancelRideOptions(cancelFunc: {})
}
