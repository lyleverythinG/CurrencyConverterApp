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
    
    var description: String {
        switch self {
        case .apiError(let message):
            return "API Error: \(message)"
        case .invalidURL:
            return "Invalid URL: The URL provided was not valid."
        case .invalidServerResponse:
            return "Invalid Server Response: The server response was not as expected."
        case .unexpectedError(let message):
            return "Unexpected Error: \(message)"
        case .noDataReceived:
            return "No Data Received: No data was received from the server."
        case .decodingError(let message):
            return "Decoding Error: There was an error decoding the server response. \(message)"
        case .exchangeRateNotFound(let currency):
            return "Exchange Rate Not Found: Could not find an exchange rate for \(currency)."
        }
    }
}
