import SwiftUI

struct ExchangeInfo: View {
    @Environment(\.dismiss) var dismiss
    @State private var usdToPhp: Double?
    @State private var phpToHkd: Double?
    @State private var hkdToPhp: Double?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            // Background Image
            Image(.parchment)
                .resizable()
                .ignoresSafeArea()
                .background(.brown)
            
            VStack {
                // Exchange Rates Text
                CCText.largeTitle("Exchange Rates")
                    .tracking(3)
                
                // Description
                CCText.title2("Real-time Rates Info")
                    .padding()
                
                if isLoading {
                    ProgressView("Loading exchange rates...")
                } else {
                    // Display the exchange rates if they are loaded
                    if let usdToPhp = usdToPhp {
                        ExchangeRate(leftImage: .usd, text: "1 US Dollar = \(String(format: "%.2f", usdToPhp)) Philippine Peso", rightImage: .php)
                    }
                    if let phpToHkd = phpToHkd {
                        ExchangeRate(leftImage: .php, text: "1 Philippine Peso = \(String(format: "%.2f", phpToHkd)) HKD", rightImage: .hkd)
                    }
                    if let hkdToPhp = hkdToPhp {
                        ExchangeRate(leftImage: .hkd, text: "1 HKD = \(String(format: "%.2f", hkdToPhp)) Philippine Peso", rightImage: .php)
                    }
                }
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.brown)
                .font(.largeTitle)
                .padding()
                .foregroundStyle(.white)
            }
            .foregroundStyle(.black)
        }
        .onAppear(perform: fetchExchangeRates)
    }
    
    private func fetchExchangeRates() {
        let service = ExchangeRateService()
        
        let group = DispatchGroup()
        
        group.enter()
        service.fetchExchangeRates(baseCurrency: "USD", targetCurrency: "PHP") { result in
            switch result {
            case .success(let rate):
                self.usdToPhp = rate
            case .failure(let error):
                print("Error fetching USD to PHP rate: \(error)")
            }
            group.leave()
        }
        
        group.enter()
        service.fetchExchangeRates(baseCurrency: "PHP", targetCurrency: "HKD") { result in
            switch result {
            case .success(let rate):
                self.phpToHkd = rate
            case .failure(let error):
                print("Error fetching PHP to HKD rate: \(error)")
            }
            group.leave()
        }
        
        group.enter()
        service.fetchExchangeRates(baseCurrency: "HKD", targetCurrency: "PHP") { result in
            switch result {
            case .success(let rate):
                self.hkdToPhp = rate
            case .failure(let error):
                print("Error fetching HKD to PHP rate: \(error)")
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
        }
    }
}
#Preview {
    ExchangeInfo()
}

