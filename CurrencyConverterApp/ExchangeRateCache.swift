
import Foundation

class PersistentExchangeRateCache {
    static let shared = PersistentExchangeRateCache()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    private func cacheKey(baseCurrency: String, targetCurrency: String) -> String {
        return "\(baseCurrency)-\(targetCurrency)"
    }
    
    private func timestampKey(baseCurrency: String, targetCurrency: String) -> String {
        return "\(baseCurrency)-\(targetCurrency)-timestamp"
    }
    
    func getExchangeRate(baseCurrency: String, targetCurrency: String) -> Double? {
        let key = cacheKey(baseCurrency: baseCurrency, targetCurrency: targetCurrency)
        let rate = defaults.double(forKey: key)
        let timestamp = defaults.double(forKey: timestampKey(baseCurrency: baseCurrency, targetCurrency: targetCurrency))
        
        // Example: 24-hour expiration
        let isExpired = Date().timeIntervalSince1970 - timestamp > 24 * 60 * 60
        if isExpired {
            return nil // Return nil when expired.
        }
        
        return rate != 0.0 ? rate : nil
    }
    
    func setExchangeRate(baseCurrency: String, targetCurrency: String, rate: Double) {
        let key = cacheKey(baseCurrency: baseCurrency, targetCurrency: targetCurrency)
        defaults.set(rate, forKey: key)
        
        let timestampKey = timestampKey(baseCurrency: baseCurrency, targetCurrency: targetCurrency)
        defaults.set(Date().timeIntervalSince1970, forKey: timestampKey)
        
        print(String(format: "Save rate: %.2f for key \(key)", rate))

    }
}
