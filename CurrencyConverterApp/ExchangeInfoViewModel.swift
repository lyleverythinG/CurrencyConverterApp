//
//  ExchangeInfoViewModel.swift
//  CurrencyConverterApp
//
//  Created by Lyle Dane Carcedo on 12/4/24.
//
import SwiftUI

class ExchangeInfoViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var exchangeRates: [ExchangeRateModel] = []
    
    private let cache = ExchangeRateCache.shared
    private let service = ExchangeRateService()
    
    private func generateExchangeRateModels(
        usdToPhp: Double? = nil,
        phpToHkd: Double? = nil,
        hkdToPhp: Double? = nil
    ) -> [ExchangeRateModel] {
        return [
            ExchangeRateModel(
                leftImage: Currency.usdCurrency.image,
                text: "1 US Dollar = \(usdToPhp ?? 0.0) PHP",
                rightImage: Currency.phpCurrency.image
            ),
            ExchangeRateModel(
                leftImage: Currency.phpCurrency.image,
                text: "1 Philippine Peso = \(phpToHkd ?? 0.0) HKD",
                rightImage: Currency.hkdCurrency.image
            ),
            ExchangeRateModel(
                leftImage: Currency.hkdCurrency.image,
                text: "1 HKD = \(hkdToPhp ?? 0.0) PHP",
                rightImage: Currency.phpCurrency.image
            )
        ]
    }
    
    func fetchExchangeRatesInfo() {
        let group = DispatchGroup()
        
        var usdToPhpRate: Double?
        var phpToHkdRate: Double?
        var hkdToPhpRate: Double?
        
        let exchangeConfigurations = [
            (Currency.usdCurrency.rawValue, Currency.phpCurrency.rawValue, { rate in usdToPhpRate = rate }),
            (Currency.phpCurrency.rawValue, Currency.hkdCurrency.rawValue, { rate in phpToHkdRate = rate }),
            (Currency.hkdCurrency.rawValue, Currency.phpCurrency.rawValue, { rate in hkdToPhpRate = rate })
        ]
        
        
        for (baseCurrency, targetCurrency, assignRate) in exchangeConfigurations {
            group.enter()
            
            if let cachedRate = cache.getExchangeRate(baseCurrency: baseCurrency, targetCurrency: targetCurrency) {
                // Use cached rate if available
                print(String(format: "Using cached rate for \(baseCurrency) to \(targetCurrency): %.2f", cachedRate))
                assignRate(cachedRate)
                group.leave()
            } else {
                // Fetch new rate if not yet in cache
                service.fetchExchangeRates(baseCurrency: baseCurrency, targetCurrency: targetCurrency) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let rate):
                            print(String(format: "Fetched new rate for \(baseCurrency) to \(targetCurrency): %.2f", rate))
                            self.cache.setExchangeRate(baseCurrency: baseCurrency, targetCurrency: targetCurrency, rate: rate)
                            assignRate(rate)
                        case .failure(let error):
                            print("Error fetching \(baseCurrency) to \(targetCurrency) rate: \(error)")
                        }
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            self.exchangeRates = self.generateExchangeRateModels(usdToPhp: usdToPhpRate, phpToHkd: phpToHkdRate, hkdToPhp: hkdToPhpRate)
            self.isLoading = false
        }
    }
}
