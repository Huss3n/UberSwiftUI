//
//  Profile.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 31/08/2024.
//

import SwiftUI

struct Profile: View {
    var body: some View {
        VStack {
            header
            
            ScrollView {
                VStack {
                    Image(systemName: "")
                }
            }
            
        }
        .padding(.horizontal)
    }
}

#Preview {
    Profile()
}



extension Profile {
    private var header: some View {
        HStack(alignment: .top) {
            VStack {
                Text("Hussein Aisak")
                    .font(.title)
                    .fontWeight(.semibold)
                
                HStack {
                    Image(systemName: "star.fill")
                    Text("4.9")
                }
                .padding(6)
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .cornerRadius(40)
            }
            
            Spacer()
            
            Image(systemName: "person.fill")
                .foregroundStyle(.gray)
                .font(.largeTitle)
                .padding(20)
                .background(Color(.systemGray6))
                .clipShape(Circle())
        }
    }
}
