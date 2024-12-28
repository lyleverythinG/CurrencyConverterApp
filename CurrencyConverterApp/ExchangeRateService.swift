//
//  ExchangeRateService.swift
//  CurrencyConverter
//
//  Created by Lyle Dane Carcedo on 7/22/24.
//

import Foundation

class ExchangeRateService {
    private let apiKey = ""//TODO: Add your own API key.
    private let baseURL = "https://api.freecurrencyapi.com/v1/latest"
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func fetchExchangeRates(baseCurrency: String, targetCurrency: String, completion: @escaping (Result<Double, ExchangeRateError>) -> Void) {
        guard let url = buildURL(baseCurrency: baseCurrency, targetCurrency: targetCurrency) else {
            completion(.failure(.invalidURL))
            return
        }
        
        urlSession.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.completeOnMainThread(.failure(.apiError(error.localizedDescription)), completion)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self.completeOnMainThread(.failure(.invalidServerResponse), completion)
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let message = self.decodeAPIErrorMessage(from: data) {
                    self.completeOnMainThread(.failure(.apiError(message)), completion)
                } else {
                    let errorDescription = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                    let detailedErrorMessage = "HTTP Status Code: \(httpResponse.statusCode) - \(errorDescription)"
                    self.completeOnMainThread(.failure(.unexpectedError(detailedErrorMessage)), completion)
                }
                return
            }
            
            guard let data = data else {
                self.completeOnMainThread(.failure(.noDataReceived), completion)
                return
            }
            
            do {
                let exchangeRate = try self.decodeExchangeRate(from: data, targetCurrency: targetCurrency)
                self.completeOnMainThread(.success(exchangeRate), completion)
            } catch let error as ExchangeRateError {
                self.completeOnMainThread(.failure(error), completion)
            } catch {
                self.completeOnMainThread(.failure(.decodingError(error.localizedDescription)), completion)
            }
        }.resume()
    }
    
    private func buildURL(baseCurrency: String, targetCurrency: String) -> URL? {
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "currencies", value: targetCurrency),
            URLQueryItem(name: "base_currency", value: baseCurrency)
        ]
        return urlComponents?.url
    }
    
    private func decodeAPIErrorMessage(from data: Data?) -> String? {
        guard let data = data else { return nil }
        return try? JSONDecoder().decode(APIErrorResponse.self, from: data).message
    }
    
    private func decodeExchangeRate(from data: Data, targetCurrency: String) throws -> Double {
        let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
        guard let rate = response.data[targetCurrency] else {
            throw ExchangeRateError.exchangeRateNotFound(targetCurrency)
        }
        return rate
    }
    
    private func completeOnMainThread<T>(_ result: Result<T, ExchangeRateError>, _ completion: @escaping (Result<T, ExchangeRateError>) -> Void) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}
