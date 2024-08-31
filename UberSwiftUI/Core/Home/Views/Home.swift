//
//  Home.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 24/08/2024.
//

import SwiftUI

struct Home: View {
    @State var mapState: MapState = .noInput
    @EnvironmentObject var locationSearchVM: LocationSearchVM
    @State private var showProfileView: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            ZStack(alignment: .top) {
                UberMapView(mapState: $mapState)
                    .ignoresSafeArea()
                
                if mapState == .searchingForLocation {
                    SearchView(mapState: $mapState)
                    
                } else if mapState == .noInput {
                    LocationSearchView()
                        .padding(.top, 64)
                        .onTapGesture {
                            withAnimation(.spring) {
                                mapState = .searchingForLocation
                            }
                        }
                }
                HumbugerButton(mapState: $mapState)
            }
            
            if mapState == .locationSelected {
                RequestPop()
                    .transition(.move(edge: .bottom))
                    .zIndex(1)  
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onReceive(LocationManager.shared.$userLocation, perform: { location in
            locationSearchVM.userLocation = location
        })
        .onChange(of: mapState) {
            if mapState == .profile {
                showProfileView.toggle()
            }
        }
        .navigationDestination(isPresented: $showProfileView, destination: {
            Profile()
                .navigationBarBackButtonHidden()
                .onDisappear {
                    mapState = .noInput
                }
        })
    }
}

//
//#Preview {
//    Home()
//}
