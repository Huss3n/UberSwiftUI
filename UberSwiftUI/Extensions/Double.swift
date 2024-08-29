//
//  Double.swift
//  UberSwiftUI
//
//  Created by Muktar Aisak on 29/08/2024.
//

import Foundation

extension Double {
    private var currencyFormat: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    private func roundedAmount() -> Double {
        let roundingInterval: Double = 10
        return (self / roundingInterval).rounded() * roundingInterval
    }
    
    func toCurrency() -> String {
        let roundedValue = roundedAmount()
        return currencyFormat.string(for: roundedValue) ?? "N/A"
    }
}
