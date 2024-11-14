
import SwiftUI

enum Currency: String, CaseIterable, Identifiable {
    case phpCurrency = "PHP"
    case usdCurrency = "USD"
    case hkdCurrency = "HKD"
    
    var id: Currency { self }
    var image: ImageResource {
        switch self {
        case .phpCurrency:
            return .php
        case .usdCurrency:
            return .usd
        case .hkdCurrency:
            return .hkd
        }
    }
    
    var name: String {
        switch self {
        case .phpCurrency:
            return "Philippine Peso"
        case .usdCurrency:
            return "US Dollar"
        case .hkdCurrency:
            return "Hong Kong Dollar"
        }
    }
    
    /// Converts an amount from the current currency to the target currency.
    /// - Parameters:
    ///   - amountString: The amount to convert as a string.
    ///   - currency: The target currency.
    ///   - exchangeRate: The exchange rate between the current and target currencies.
    /// - Returns: The converted amount as a string, or an empty string if the input is invalid.
    func convert(_ amountString: String, to currency: Currency, exchangeRate: Double) -> String {
         guard let doubleAmount = Double(amountString) else {
             return ""
         }
         
         let convertedAmount = doubleAmount * exchangeRate
         
         let decimalAmount = NSDecimalNumber(value: convertedAmount)
        let roundingBehavior = NSDecimalNumberHandler(
            roundingMode: .plain,
            scale: 2,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        let roundedAmount = decimalAmount.rounding(accordingToBehavior: roundingBehavior)
         
         return roundedAmount.stringValue
     }
}
