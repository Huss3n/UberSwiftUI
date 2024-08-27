//
//  Home.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 24/08/2024.
//

import SwiftUI

struct Home: View {
    @State private var mapState: MapState = .noInput
    
    var body: some View {
        ZStack(alignment: .top) {
            UberMapView(mapState: $mapState)
                .ignoresSafeArea()
            
            if mapState == .searchingForLocation {
                SearchView(mapState: $mapState)
            
            } else if mapState == .noInput {
                LocationSearchView()
                    .padding(.top, 58)
                    .onTapGesture {
                        withAnimation(.spring) {
                            mapState = .searchingForLocation
                        }
                    }
            }
            
            HumbugerButton(mapState: $mapState)
        }
    }
}

//
//#Preview {
//    Home()
//}
