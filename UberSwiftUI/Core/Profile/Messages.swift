//
//  Messages.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 31/08/2024.
//

import SwiftUI

struct Messages: View {
    @Binding var showMessages: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .fill(.green)
                        .frame(width: 70, height: 70)
                        .overlay {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white)
                                .font(.largeTitle.bold())
                                .foregroundStyle(.black)
                        }
                        .cornerRadius(10)
                    
                    Rectangle()
                        .fill(.primary)
                        .frame(width: 70, height: 10)
                        .cornerRadius(10)
                }
                
                Text("You are all up to date")
                    .font(.title.bold())
                
                VStack(spacing: 8) {
                    Text("No new messages available at the moment")
                    Text("- come back soon to discover new offers")
                }
                .fontWeight(.light)
            }
            .navigationTitle("Offers & messages")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "xmark")
                        .onTapGesture {
                            showMessages.toggle()
                        }
                }
            }
        }
    }
}

#Preview {
    Messages(showMessages: .constant(true))
}
