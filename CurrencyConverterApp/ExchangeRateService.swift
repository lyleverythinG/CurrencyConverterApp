//
//  ExchangeRateService.swift
//  CurrencyConverter
//
//  Created by Lyle Dane Carcedo on 7/22/24.
//

import Foundation

class ExchangeRateService {
    private let apiKey = ""// TODO: Add your own API key.
    private let baseURL = "https://api.freecurrencyapi.com/v1/latest"

    func fetchExchangeRates(baseCurrency: String, targetCurrency: String, completion: @escaping (Result<Double, Error>) -> Void) {
        guard var urlComponents = URLComponents(string: baseURL) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "currencies", value: targetCurrency),
            URLQueryItem(name: "base_currency", value: baseCurrency)
        ]
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let exchangeRateResponse = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
                if let exchangeRate = exchangeRateResponse.data[targetCurrency] {
                    completion(.success(exchangeRate))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Exchange rate not found"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
