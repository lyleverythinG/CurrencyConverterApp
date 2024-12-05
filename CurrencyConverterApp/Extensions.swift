//
//  StringExtension.swift
//  CurrencyConverterApp
//
//  Created by Lyle Dane Carcedo on 12/6/24.
//

import SwiftUI

extension Double {
    /// Converts a double to a formatted string with the specified number of decimal places.
    /// - Parameter decimalPlaces: The number of decimal places to include. Default is 2.
    /// - Returns: A string representation of the double with the specified decimal places.
    func formattedCurrencyStringVal(withDecimalPlaces decimalPlaces: Int = 2) -> String {
        return String(format: "%.\(decimalPlaces)f", self)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
