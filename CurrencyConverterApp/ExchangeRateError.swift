//
//  ExchangeRateError.swift
//  CurrencyConverterApp
//
//  Created by Lyle Dane Carcedo on 12/6/24.
//

import Foundation

struct APIErrorResponse: Decodable {
    let message: String
}

enum ExchangeRateError: Error {
    case apiError(String)
    case invalidURL
    case invalidServerResponse
    case unexpectedError(String)
    case noDataReceived
    case exchangeRateNotFound(String)
    case decodingError(String)
}
