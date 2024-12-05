//
//  CurrencyField.swift
//  CurrencyConverterApp
//
//  Created by Lyle Dane Carcedo on 12/6/24.
//

import Foundation

enum CurrencyField {
    case left
    case right
    
    var key: String {
        switch self {
        case .left: return "leftCurrency"
        case .right: return "rightCurrency"
        }
    }
}
