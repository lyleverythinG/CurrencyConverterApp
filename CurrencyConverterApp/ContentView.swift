import SwiftUI
import TipKit

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct ContentView: View {
    @State var showExchangeInfo = false
    @State var showSelectCurrency = false
    @State var leftAmount = ""
    @State var rightAmount = ""
    @FocusState var leftTyping
    @FocusState var rightTyping
    @State var leftCurrency = Currency.usdCurrency
    @State var rightCurrency = Currency.phpCurrency
    @State var exchangeRate: Double = 1.0
    @State var isLoading = false
    
    var body: some View {
        ZStack {
            // Background Image
            Image(.background)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                // Currency Exchange image view
                Image(.exchangerate)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                //Currency exchange text
                Text("Currency Exchange")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                
                //Currency conversion section
                HStack {
                    // Left conversion
                    LeftConversionFieldView(currency:leftCurrency, amount: $leftAmount, isTyping: $leftTyping, showSelectCurrency: $showSelectCurrency)
                    
                    //Equal sign
                    Image(systemName: "equal")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .symbolEffect(.pulse)
                    
                    //Right conversion
                    RightConversionFieldView(currency: rightCurrency, amount: $rightAmount, isTyping: $rightTyping, showSelectCurrency: $showSelectCurrency)
                }
                .padding()
                .background(.black.opacity(0.5))
                .clipShape(.capsule)
                Spacer()
                
                // Info Button
                InfoButton(showExchangeInfo: $showExchangeInfo)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .task {
            try? Tips.configure()
        }
        .onChange(of: leftAmount) {_, _ in
            if leftTyping {
                fetchExchangeRate(baseCurrency: leftCurrency.rawValue, targetCurrency: rightCurrency.rawValue) { rate in
                    self.exchangeRate = rate
                    rightAmount = leftCurrency.convert(leftAmount, to: rightCurrency, exchangeRate: rate)
                }
            }
        }
        .onChange(of: rightAmount) {_, _ in
            if rightTyping {
                fetchExchangeRate(baseCurrency: rightCurrency.rawValue, targetCurrency: leftCurrency.rawValue) { rate in
                    self.exchangeRate = rate
                    leftAmount = rightCurrency.convert(rightAmount, to: leftCurrency, exchangeRate: rate)
                }
            }
        }
        .onChange(of: leftCurrency) {_, _ in
            fetchExchangeRate(baseCurrency: leftCurrency.rawValue, targetCurrency: rightCurrency.rawValue) { rate in
                self.exchangeRate = rate
                leftAmount = rightCurrency.convert(rightAmount, to: leftCurrency, exchangeRate: rate)
            }
        }
        .onChange(of: rightCurrency) {_, _ in
            fetchExchangeRate(baseCurrency: leftCurrency.rawValue, targetCurrency: rightCurrency.rawValue) { rate in
                self.exchangeRate = rate
                rightAmount = leftCurrency.convert(leftAmount, to: rightCurrency, exchangeRate: rate)
            }
        }
        .onAppear {
            fetchExchangeRate(baseCurrency: leftCurrency.rawValue, targetCurrency: rightCurrency.rawValue, forceFetch: false) { rate in
                self.exchangeRate = rate
                rightAmount = leftCurrency.convert(leftAmount, to: rightCurrency, exchangeRate: rate)
            }
        }
        .sheet(isPresented: $showExchangeInfo) {
            ExchangeInfo()
        }
        .sheet(isPresented: $showSelectCurrency) {
            SelectCurrency(topCurrency: $leftCurrency, bottomCurrency: $rightCurrency)
        }
    }
    
    private func fetchExchangeRate(baseCurrency: String, targetCurrency: String, forceFetch: Bool = false, completion: @escaping (Double) -> Void) {
        self.isLoading = true
        
        let cache = PersistentExchangeRateCache.shared
        
        // Check if we need to force fetching new data
        if forceFetch || cache.getExchangeRate(baseCurrency: baseCurrency, targetCurrency: targetCurrency) == nil {
            ExchangeRateService().fetchExchangeRates(baseCurrency: baseCurrency, targetCurrency: targetCurrency) { result in
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch result {
                    case .success(let rate):
                        print(String(format: "Fetched new rate: %.2f", rate))
                        cache.setExchangeRate(baseCurrency: baseCurrency, targetCurrency: targetCurrency, rate: rate)
                        completion(rate)
                    case .failure(let error):
                        print("Error fetching exchange rate: \(error)")
                    }
                }
            }
        } else {
            // Use cached rate if available
            if let cachedRate = cache.getExchangeRate(baseCurrency: baseCurrency, targetCurrency: targetCurrency) {
                DispatchQueue.main.async {
                    print(String(format: "Using cached rate: %.2f", cachedRate))
                    self.isLoading = false
                    completion(cachedRate)
                }
            }
        }
    }
    
    private struct LeftConversionFieldView: View {
        var currency: Currency
        @Binding var amount: String
        var isTyping: FocusState<Bool>.Binding
        @Binding var showSelectCurrency: Bool
        
        var body: some View {
            VStack {
                // Currency
                HStack {
                    Image(currency.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 33)
                    Text(currency.name)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }
                .padding(.bottom, -5)
                .onTapGesture {
                    showSelectCurrency.toggle()
                }
                .popoverTip(CurrencyTip(), arrowEdge: .bottom)
                
                // TextField
                TextField("Amount", text: $amount)
                    .textFieldStyle(.roundedBorder)
                    .focused(isTyping)
                    .keyboardType(.decimalPad)
            }
        }
    }
    
    private struct RightConversionFieldView: View {
        var currency: Currency
        @Binding var amount: String
        var isTyping: FocusState<Bool>.Binding
        @Binding var showSelectCurrency: Bool
        
        var body: some View {
            VStack {
                // Currency
                HStack {
                    Text(currency.name)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    Image(currency.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 33)
                }
                .padding(.bottom, -5)
                .onTapGesture {
                    showSelectCurrency.toggle()
                }
                // TextField
                TextField("Amount", text: $amount)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .focused(isTyping)
                    .keyboardType(.decimalPad)
            }
        }
    }
    
    private struct InfoButton: View {
        @Binding var showExchangeInfo: Bool
        
        var body: some View {
            HStack {
                Spacer()
                Button {
                    showExchangeInfo.toggle()
                    print("showExchangeInfo value: \(showExchangeInfo)")
                    
                } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                }
                .padding(.trailing)
            }
        }
    }
}
