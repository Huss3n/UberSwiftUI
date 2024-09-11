//
//  VerificationCodeView.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 10/09/2024.
//

import SwiftUI

struct VerificationCodeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var code: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?
    @ObservedObject var authVM: AuthVM
    @State private var errorMessage: String?
    @Binding var successfulAuth: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            Image(systemName: "xmark")
                .padding(10)
                .font(.headline)
                .background(.gray.opacity(0.2))
                .clipShape(Circle())
                .frame(maxWidth: .infinity, alignment: .trailing)
                .onTapGesture {
                    dismiss()
                }
                
            
            Text("Enter the code sent to the provided phone number")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack(spacing: 14) {
                ForEach(0..<6, id: \.self) { index in
                    TextField("", text: $code[index])
                        .frame(width: 40, height: 50)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: index)
                        .onChange(of: code[index]) { newValue in
                            if newValue.count > 1 {
                                code[index] = String(newValue.prefix(1))
                            }
                            if !newValue.isEmpty && index < 5 {
                                focusedField = index + 1
                            }
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification)) { _ in
                            if code[index].isEmpty && index > 0 {
                                focusedField = index - 1
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            
            Text(errorMessage ?? "")
                .foregroundStyle(.red)
                .font(.caption)
                .multilineTextAlignment(.center)
                .opacity(errorMessage == nil ? 0 : 1)
            
            Button(action: {
                Task {
                    await verifyCode()
                }
            }) {
                Text("Verify")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
        
            Spacer()
        }
        .padding()
        .onAppear {
            focusedField = 0
        }
    }
    
    func verifyCode() async {
        let enteredCode = code.joined()
        
        do {
            try await authVM.verifyCode(enteredCode) { completion in
                if completion {
                    dismiss()
                    successfulAuth = true
                }
            }
        } catch {
            print(error.localizedDescription)
            self.errorMessage = "The code entered is not correct"
        }
    }
}

#Preview {
    VerificationCodeView(authVM: AuthVM(), successfulAuth: .constant(true))
}

