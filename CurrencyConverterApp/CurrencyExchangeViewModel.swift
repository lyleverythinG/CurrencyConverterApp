//
//  CurrencyViewModel.swift
//  CurrencyConverterApp
//
//  Created by Lyle Dane Carcedo on 12/4/24.
//

import Foundation

final class CurrencyExchangeViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var exchangeRate: Double = 1.0
    @Published var showExchangeInfo = false
    @Published var showSelectCurrency = false
    @Published var leftAmount = ""
    @Published var rightAmount = ""
    @Published var leftCurrency: Currency = .usdCurrency {
        didSet {
            ExchangeRateCache.shared.setCachedCurrency(leftCurrency, field: .left)
        }
    }
    @Published var rightCurrency: Currency = .phpCurrency {
        didSet {
            ExchangeRateCache.shared.setCachedCurrency(rightCurrency, field: .right)
        }
    }
    
    private let exchangeRateService = ExchangeRateService()
    private let cache = ExchangeRateCache.shared
    
    init() {
        self.leftCurrency = cache.getCachedCurrency(for: .left) ?? .usdCurrency
        self.rightCurrency = cache.getCachedCurrency(for: .right) ?? .phpCurrency
    }
    
    func fetchExchangeRate(
        baseCurrency: String,
        targetCurrency: String,
        forceFetch: Bool = false,
        completion: @escaping (Result<Double, ExchangeRateError>) -> Void
    ) {
        var retryAttempts = 1
        isLoading = true
        
        func attemptFetch() {
            // Check the cache first
            if !forceFetch, let cachedRate = cache.getExchangeRate(baseCurrency: baseCurrency, targetCurrency: targetCurrency) {
                DispatchQueue.main.async {
                    print(String(format: "Using cached rate for %@ -> %@: %.2f", baseCurrency, targetCurrency, cachedRate))
                    self.isLoading = false
                    completion(.success(cachedRate))
                }
                return
            }
            
            // Attempt to fetch from API
            exchangeRateService.fetchExchangeRates(baseCurrency: baseCurrency, targetCurrency: targetCurrency) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let rate):
                        print(String(format: "Fetched new rate for %@ -> %@: %.2f", baseCurrency, targetCurrency, rate))
                        self.cache.setExchangeRate(baseCurrency: baseCurrency, targetCurrency: targetCurrency, rate: rate)
                        self.exchangeRate = rate
                        self.isLoading = false
                        completion(.success(rate))
                        
                    case .failure(let error):
                        print("Error fetching exchange rate: \(error.description)")
                        
                        if retryAttempts > 0 {
                            print("Retrying... Remaining attempts: \(retryAttempts - 1)")
                            retryAttempts -= 1
                            attemptFetch()
                        } else {
                            // If all retries fail, fallback to cache or return an error
                            if let cachedRate = self.cache.getExchangeRate(baseCurrency: baseCurrency, targetCurrency: targetCurrency) {
                                print(String(format: "Fallback to cached rate for %@ -> %@: %.2f", baseCurrency, targetCurrency, cachedRate))
                                self.exchangeRate = cachedRate
                                completion(.success(cachedRate))
                            } else {
                                completion(.failure(error))
                            }
                            self.isLoading = false
                        }
                    }
                }
            }
        }
        
        attemptFetch()
    }
    
    func convertAmount(baseCurrency: Currency,targetCurrency: Currency, sourceAmount: String, updateTargetAmount: @escaping (String) -> Void) {
        fetchExchangeRate(baseCurrency: baseCurrency.rawValue, targetCurrency: targetCurrency.rawValue) { result in
            switch result {
            case .success(let rate):
                let convertedAmount = baseCurrency.convert(sourceAmount, to: targetCurrency, exchangeRate: rate)
                updateTargetAmount(convertedAmount)
            case .failure(let error):
                print("Error converting amount from \(baseCurrency.rawValue) to \(targetCurrency.rawValue): \(error.description)")
            }
        }
    }
    
    func handleCurrencyChange(currencyField: CurrencyField) {
        let baseCurrency: Currency
        let targetCurrency: Currency
        
        switch currencyField {
        case .left:
            baseCurrency = leftCurrency
            targetCurrency = rightCurrency
        case .right:
            baseCurrency = rightCurrency
            targetCurrency = leftCurrency
        }
        
        fetchExchangeRate(baseCurrency: baseCurrency.rawValue, targetCurrency: targetCurrency.rawValue) { result in
            switch result {
            case .success(let rate):
                if currencyField == .left {
                    self.rightAmount = self.leftCurrency.convert(self.leftAmount, to: self.rightCurrency, exchangeRate: rate)
                } else {
                    self.leftAmount = self.rightCurrency.convert(self.rightAmount, to: self.leftCurrency, exchangeRate: rate)
                }
            case .failure(let error):
                print("Error handling currency change for \(currencyField): \(error.localizedDescription)")
            }
        }
    }
}
