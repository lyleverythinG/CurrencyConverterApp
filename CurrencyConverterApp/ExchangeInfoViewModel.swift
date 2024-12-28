//
//  ExchangeInfoViewModel.swift
//  CurrencyConverterApp
//
//  Created by Lyle Dane Carcedo on 12/4/24.
//
import SwiftUI

final class ExchangeInfoViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var exchangeRates: [ExchangeRateModel] = []
    
    private let cache = ExchangeRateCache.shared
    private let service = ExchangeRateService()
    
    private func generateExchangeRateModels(
        usdToPhp: Double,
        phpToHkd: Double,
        hkdToPhp: Double
    ) -> [ExchangeRateModel] {
        return [
            ExchangeRateModel(
                leftImage: Currency.usdCurrency.image,
                text: "1 US Dollar = \(usdToPhp.formattedCurrencyStringVal()) PHP",
                rightImage: Currency.phpCurrency.image
            ),
            ExchangeRateModel(
                leftImage: Currency.phpCurrency.image,
                text: "1 Philippine Peso = \(phpToHkd.formattedCurrencyStringVal()) HKD",
                rightImage: Currency.hkdCurrency.image
            ),
            ExchangeRateModel(
                leftImage: Currency.hkdCurrency.image,
                text: "1 HKD = \(hkdToPhp.formattedCurrencyStringVal()) PHP",
                rightImage: Currency.phpCurrency.image
            )
        ]
    }
    
    func fetchExchangeRatesInfo() {
        let group = DispatchGroup()
        
        var usdToPhpRate: Double = 0.0
        var phpToHkdRate: Double = 0.0
        var hkdToPhpRate: Double = 0.0
        
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
