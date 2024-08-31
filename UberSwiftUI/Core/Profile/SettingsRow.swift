//
//  SettingsRow.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 31/08/2024.
//

import SwiftUI

struct SettingsRow: View {
    var systemImage: String
    var title: String
    var subtitle: String?
    var showIcon: Bool? = false
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: systemImage)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.title2)
                    
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .fontWeight(.light)
                    }
                }
                
                Spacer()
                
                if showIcon ?? false {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                }
            }
            
            if showIcon ?? false {
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(height: 0.3)
            }
            
          
        }
        .padding(.horizontal)
    }
}

#Preview {
    SettingsRow(systemImage: "person.3.fill", title: "Family", subtitle: "Manage a family profile", showIcon: true)
}
