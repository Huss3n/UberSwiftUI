//
//  Wallet.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 02/09/2024.
//

import SwiftUI

struct Wallet: View {
    @Binding var showWallet: Bool
    
    var body: some View {
        NavigationStack {
            
            VStack {
                ScrollView {
                    balanceCard
                    payments
                    tripProfile
                    vouchers
                    promotions
                  
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Wallert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .onTapGesture {
                            showWallet.toggle()
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    Wallet(showWallet: .constant(true))
}


extension Wallet {
    private var balanceCard: some View {
        Rectangle()
            .fill(
                LinearGradient(colors: [.black.opacity(0.5), Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
            )
            .frame(height: 200)
            .cornerRadius(10)
            .overlay {
                VStack(alignment: .leading, spacing: 30) {
                    Text("Uber Cash")
                        .font(.headline)
                    
                    HStack {
                        Text("Ksh 700.00")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.black)
                    }
                    .font(.title)
                    .fontDesign(.monospaced)
                    
                    Button(action: {}, label: {
                        Text("+ Add Funds")
                            .foregroundStyle(.black)
                            .font(.headline)
                            .padding()
                            .background(.white.opacity(0.6))
                            .clipShape(Capsule())
                    })
                    
                }
                .padding(.horizontal)
                .foregroundStyle(Color(.systemGray6))
            }
            .padding(.vertical)
    }

    private func paymentMethods(imageName: String, paymentName: String) -> some View {
        VStack {
            HStack(spacing: 26) {
                Image(imageName)
                    .resizable()
                    .frame(width: 50, height: 40)
                
                Text(paymentName)
                    .font(.headline)
                
                Spacer()
            }
            
            Divider()
        }
    }
    
    private var payments: some View {
        VStack {
            Text("Payment Methods")
                .font(.headline)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            paymentMethods(imageName: "pesa", paymentName: "M-Pesa")
            paymentMethods(imageName: "money", paymentName: "Cash")
            
            Button(action: {}, label: {
                Text("+ Add payment method")
                    .foregroundStyle(.white)
                    .font(.headline)
                    .padding(10)
                    .background(Color(.systemGray))
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, alignment: .leading)
            })
            .padding(.vertical)
        }
    }
    
    private var tripProfile: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Trip profiles")
                .font(.headline)
            HStack {
                Image(systemName: "person.fill")
                    .padding(10)
                    .background(.gray.opacity(0.3))
                    .clipShape(Circle())
                
                Text("Personal")
            }
            
            Divider()
            
            HStack {
                Image(systemName: "briefcase")
                    .padding(10)
                    .background(.gray.opacity(0.3))
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text("Start using uber for business")
                    Text("Turn on business travel features")
                        .foregroundStyle(.blue)
                        .font(.subheadline)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var vouchers: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vouchers")
                .font(.headline)
            
            HStack {
                Image(systemName: "menucard")
                Text("Vouchers")
                Spacer()
                Text("0")
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray)
            }
            
            Divider()
            
            Text("+ Add voucher code")
            Divider()
            
        }
        .padding(.vertical)
    }
    
    private var promotions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Promotions")
                .font(.headline)
            
            HStack {
                Image(systemName: "tag")
                Text("Promotions")
                Spacer()
                Text("3")
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray)
            }
            Divider()
            
            Text("+ Add promo code")
            Divider()
            
        }
        .padding(.vertical)
    }
        

}
