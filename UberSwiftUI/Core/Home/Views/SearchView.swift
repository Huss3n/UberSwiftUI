//
//  SearchView.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 26/08/2024.
//

import SwiftUI

struct SearchView: View {
    @State private var currentLocation: String = ""
    @Binding var mapState: MapState
    @EnvironmentObject var locationSearchVM: LocationSearchVM
    
    var body: some View {
        VStack {
            // MARK: Header
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
                
                VStack {
                    TextField("Current location", text: $currentLocation)
                        .padding(.leading, 8)
                        .frame(height: 32)
                        .background(Color(.systemGray6))
                    
                    TextField("Where to?", text: $locationSearchVM.querry)
                        .padding(.leading, 8)
                        .frame(height: 32)
                        .background(Color(.systemGray4))
                }
                .padding(.trailing)
                
            }
            .padding(.horizontal)
            .padding(.top, 66)
            
            Divider()
                .padding(.vertical)
            
            
            // MARK: Locations lists
            ScrollView {
                ForEach(locationSearchVM.results, id: \.self) { result in
                    LocationViewComponent(title: result.title, subtitle: result.subtitle)
                        .onTapGesture {
                            withAnimation(.spring) {
                                locationSearchVM.selectLocation(result)
                                mapState = .locationSelected
                            }
                        }
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.appTheme.backgroundColor)
    }
}

#Preview {
    SearchView(mapState: .constant(.noInput))
        .environmentObject(LocationSearchVM())
}
