//
//  LocationSearchView.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 24/08/2024.
//

import SwiftUI

struct LocationSearchView: View {
    var body: some View {
        HStack {
            
            Rectangle()
                .fill(.black)
                .frame(width: 8, height: 8)
                .padding(.horizontal)
            
            Text("Where to ?")
                .foregroundStyle(.gray)
            
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width - 64, height: 50)
        .background(
            Rectangle()
                .fill(.white)
                .shadow(color: .black, radius: 5)
                .cornerRadius(10)
        )
    }
}

#Preview {
    LocationSearchView()
}
