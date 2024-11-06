//
//  HumbugerButton.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 26/08/2024.
//

import SwiftUI

struct HumbugerButton: View {
    @Binding var mapState: MapState
    @Binding var connectToDriver: Bool
    @EnvironmentObject var locationSearchVM: LocationSearchVM
    
    var body: some View {
        Button {
            withAnimation(.spring) {
                trigger(mapState)
            }
        } label: {
            Image(systemName: imageName())
                .font(.headline)
                .foregroundColor(.black)
                .padding()
                .background(.white)
                .clipShape(Circle())
                .shadow(color: .black, radius: 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading)
        .padding(.top, 4)

    }
    
    
    func imageName() -> String {
        switch mapState {
        case .noInput, .profile:
            return "person.fill"
        case .locationSelected, .searchingForLocation:
            return "arrow.left"
        }
    }
    
    func trigger(_ state: MapState) {
        switch mapState {
        case .noInput:
            mapState = .profile
            print("Mapstate is \(mapState)")
        case .locationSelected:
            mapState = .noInput
        case .searchingForLocation:
            mapState = .noInput
            locationSearchVM.selectedTripLocation = nil
            connectToDriver = false
        case .profile:
            break
        }
    }
}

#Preview {
    HumbugerButton(mapState: .constant(.noInput), connectToDriver: .constant(false))
}
