//
//  CurrencyViewModel.swift
//  CurrencyConverterApp
//
//  Created by Lyle Dane Carcedo on 12/4/24.
//

import Foundation

class CurrencyExchangeViewModel: ObservableObject {
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
        completion: @escaping (Double) -> Void
    ) {
        isLoading = true
        
        if forceFetch || cache.getExchangeRate(baseCurrency: baseCurrency, targetCurrency: targetCurrency) == nil {
            exchangeRateService.fetchExchangeRates(baseCurrency: baseCurrency, targetCurrency: targetCurrency) { result in
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch result {
                    case .success(let rate):
                        print(String(format: "Fetched new rate: %.2f", rate))
                        self.cache.setExchangeRate(baseCurrency: baseCurrency, targetCurrency: targetCurrency, rate: rate)
                        self.exchangeRate = rate
                        completion(rate)
                    case .failure(let error):
                        print("Error fetching exchange rate: \(error)")
                    }
                }
            }
        } else if let cachedRate = cache.getExchangeRate(baseCurrency: baseCurrency, targetCurrency: targetCurrency) {
            DispatchQueue.main.async {
                print(String(format: "Using cached rate: %.2f", cachedRate))
                self.isLoading = false
                self.exchangeRate = cachedRate
                completion(cachedRate)
            }
        }
    }
    
    func convertLeftAmount() {
        fetchExchangeRate(baseCurrency: leftCurrency.rawValue, targetCurrency: rightCurrency.rawValue) { rate in
            self.rightAmount = self.leftCurrency.convert(self.leftAmount, to: self.rightCurrency, exchangeRate: rate)
        }
    }
    
    func convertRightAmount() {
        fetchExchangeRate(baseCurrency: rightCurrency.rawValue, targetCurrency: leftCurrency.rawValue) { rate in
            self.leftAmount = self.rightCurrency.convert(self.rightAmount, to: self.leftCurrency, exchangeRate: rate)
        }
    }
    
    func updateForLeftCurrencyChange() {
        fetchExchangeRate(baseCurrency: leftCurrency.rawValue, targetCurrency: rightCurrency.rawValue) { rate in
            self.leftAmount = self.rightCurrency.convert(self.rightAmount, to: self.leftCurrency, exchangeRate: rate)
        }
    }
    
    func updateForRightCurrencyChange() {
        fetchExchangeRate(baseCurrency: leftCurrency.rawValue, targetCurrency: rightCurrency.rawValue) { rate in
            self.rightAmount = self.leftCurrency.convert(self.leftAmount, to: self.rightCurrency, exchangeRate: rate)
        }
    }
}
