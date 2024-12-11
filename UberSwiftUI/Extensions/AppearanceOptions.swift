//
//  AppearanceOptions.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 20/10/2024.
//

import SwiftUI

struct AppearanceOptions: View {
    @AppStorage("selectedState") var selectedState: AppAppearance = .system
    @State private var initialSelection: AppAppearance?
    @Environment(\.dismiss) var dismiss

    init() {
        _initialSelection = State(initialValue: selectedState)
    }
    
    var body: some View {
        VStack(spacing: 18) {
            Text("Appearance")
                .font(.headline)
            
            Rectangle()
                .frame(height: 0.5)
            
            VStack {
                HStack {
                    Text("Light Mode")
                    Spacer()
                    Image(systemName: selectedState == .light ? "dot.circle.fill" : "circlebadge")
                }
                .onTapGesture {
                    selectedState = .light
                }
                
                Rectangle()
                    .frame(height: 0.3)
            }
            
            VStack {
                HStack {
                    Text("Dark Mode")
                    Spacer()
                    Image(systemName: selectedState == .dark ? "dot.circle.fill" : "circlebadge")
                }
                .onTapGesture {
                    selectedState = .dark
                }
                
                Rectangle()
                    .frame(height: 0.3)
            }
            
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Use Device Settings")
                        Text("We'll follow your device display theme")
                            .font(.caption)
                    }
                    Spacer()
                    Image(systemName: selectedState == .system ? "dot.circle.fill" : "circlebadge")
                }
                .onTapGesture {
                    selectedState = .system
                }
                
                Rectangle()
                    .frame(height: 0.3)
            }
            
            Button(action: {
                initialSelection = selectedState
                dismiss()
            }) {
                Text("Save")
                    .foregroundColor(canSave ? .blue : .gray)
            }
            .disabled(!canSave)
            
            Button("Cancel", role: .cancel) { dismiss() }
        }
        .padding(.horizontal)
    }
    
    private var canSave: Bool {
        selectedState != initialSelection
    }
}

#Preview {
    AppearanceOptions()
}

enum AppAppearance: String, Codable, CaseIterable {
    case light
    case dark
    case system
}
