//
//  LocationViewComponent.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 26/08/2024.
//

import SwiftUI

struct LocationViewComponent: View {
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "mappin")
                .font(.headline)
                .foregroundStyle(.black)
                .padding()
                .background(.blue)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .foregroundStyle(.gray)
                
                Divider()
            }
                Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    LocationViewComponent(title: "Artcaffe", subtitle: "Earth road, Kileleshwa")
}
