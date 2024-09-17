//
//  AccountTabs.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 31/08/2024.
//

import SwiftUI

protocol Filterable: RawRepresentable, Hashable, CaseIterable where RawValue == String, AllCases: RandomAccessCollection {
    var title: String { get }
}

enum HeaderFilterButtons: String, Filterable {
    case accountInfo
    case security
    case privacy

    var title: String {
        switch self {
        case .accountInfo:
            return "Account Info"
        case .security:
            return "Security"
        case .privacy:
            return "Privacy & data"
        }
    }
}

struct HeaderFilter<Filter: Filterable>: View {
    @Binding var selectedFilter: Filter
    @Namespace private var namespace

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            ForEach(Filter.allCases, id: \.rawValue) { filter in
                VStack {
                    Text(filter.title)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .fontWeight(.semibold)

                    if selectedFilter == filter {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(height: 3.5)
                            .matchedGeometryEffect(id: "selection", in: namespace)
                    }
                }
                .padding(.top, 8)
                .background(Color.black.opacity(0.001))
                .foregroundStyle(selectedFilter == filter ? Color.blue : Color.primary)
                .onTapGesture {
                    selectedFilter = filter
                }
            }
        }
        .animation(.smooth, value: selectedFilter)
    }
}

#Preview {
    HeaderFilter(selectedFilter: .constant(HeaderFilterButtons.accountInfo))
}
