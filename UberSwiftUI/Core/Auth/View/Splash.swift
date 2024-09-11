//
//  Splash.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 10/09/2024.
//

import SwiftUI

struct Splash: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Uber")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.vertical)
                
                Text("Move around safely")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Image("splash")
                    .resizable()
                    .scaledToFit()
                
                Spacer()
                
                NavigationLink {
                    AuthView()
                        .transition(.slide) 
                        .navigationBarBackButtonHidden()
                } label: {
                    HStack {
                        Text("Get Started")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(.black.opacity(0.6))
                    .cornerRadius(10)
                    .padding(.bottom, 32)
                }
                .tint(.primary)
                
            }
            .foregroundStyle(.white)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("splashBg"))
        }
        
    }
}

#Preview {
    Splash()
}
