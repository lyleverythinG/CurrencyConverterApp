
import Foundation

class ExchangeRateCache {
    static let shared = ExchangeRateCache()
    private let defaults = UserDefaults.standard
    
    private let leftCurrencyKey = "leftCurrency"
    private let rightCurrencyKey = "rightCurrency"
    
    private init() {}
    
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
    
    func getCachedCurrency (for field: CurrencyField) -> Currency? {
        guard let rawValue = defaults.string(forKey: field.key),
              let currency = Currency(rawValue: rawValue) else {
            print("Invalid or missing currency for key: \(field.key)")
            return nil
        }
        return currency
    }
    
    func setCachedCurrency(_ currency: Currency, field: CurrencyField) {
        defaults.set(currency.rawValue, forKey: field.key)
        print("Saved currency: \(currency.rawValue) for key: \(field.key)")
    }
}
