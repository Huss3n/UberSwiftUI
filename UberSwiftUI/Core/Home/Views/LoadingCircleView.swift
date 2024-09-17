//
//  CircleLoadingAnimation.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 16/09/2024.
//

import SwiftUI

struct LoadingCircleView: View {
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.lightGray), lineWidth: 8)
            Circle()
                .trim(from: 0, to: 0.2)
                .stroke(.tint, lineWidth: 6)
                .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: self.isLoading)
                .onAppear() {
                    self.isLoading = true
                }
        }
        .frame(width:70, height:70)
        .padding()
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingCircleView()
    }
}

