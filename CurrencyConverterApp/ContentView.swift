import SwiftUI
import TipKit

struct ContentView: View {
    @FocusState var leftTyping
    @FocusState var rightTyping
    @StateObject private var vm = CurrencyExchangeViewModel()
    
    var body: some View {
        ZStack {
            // Background Image
            Image(.background)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                // Currency Exchange image view
                Image(.exchangeRate)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                // Currency exchange text
                CCText.largeTitle("Currency Exchange")
                    .foregroundStyle(.white)
                
                // Currency conversion section
                HStack {
                    // Left conversion
                    LeftConversionFieldView(currency: vm.leftCurrency, amount: $vm.leftAmount, isTyping: $leftTyping, showSelectCurrency: $vm.showSelectCurrency)
                    
                    // Equal sign
                    Image(systemName: "equal")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .symbolEffect(.pulse)
                    
                    // Right conversion
                    RightConversionFieldView(currency: vm.rightCurrency, amount: $vm.rightAmount, isTyping: $rightTyping, showSelectCurrency: $vm.showSelectCurrency)
                }
                .padding()
                .background(.black.opacity(0.5))
                .clipShape(.capsule)
                Spacer()
                
                // Info Button
                InfoButton(showExchangeInfo: $vm.showExchangeInfo)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .task {
            try? Tips.configure()
        }
        .onChange(of: vm.leftAmount) { _, _ in
            if leftTyping {
                vm.convertAmount(
                    baseCurrency: vm.leftCurrency,
                    targetCurrency: vm.rightCurrency,
                    sourceAmount: vm.leftAmount
                ) { convertedAmount in
                    vm.rightAmount = convertedAmount
                }
            }
            
        }
        .onChange(of: vm.rightAmount) { _, _ in
            if rightTyping {
                vm.convertAmount(
                    baseCurrency: vm.rightCurrency,
                    targetCurrency: vm.leftCurrency,
                    sourceAmount: vm.rightAmount
                ) { convertedAmount in
                    vm.leftAmount = convertedAmount
                }
            }
        }
        .onChange(of: vm.leftCurrency) { _, _ in
            vm.handleCurrencyChange(currencyField: .left)
        }
        .onChange(of: vm.rightCurrency) { _, _ in
            vm.handleCurrencyChange(currencyField: .right)
        }
        .onAppear {
            vm.fetchExchangeRate(baseCurrency: vm.leftCurrency.rawValue, targetCurrency: vm.rightCurrency.rawValue) { result in
                switch result {
                case .success(let rate):
                    vm.rightAmount = vm.leftCurrency.convert(vm.leftAmount, to: vm.rightCurrency, exchangeRate: rate)
                case .failure(let error):
                    print("Error on initial fetch: \(error.localizedDescription)")
                }
            }
        }
        .sheet(isPresented: $vm.showExchangeInfo) {
            ExchangeInfo()
        }
        .sheet(isPresented: $vm.showSelectCurrency) {
            SelectCurrency(topCurrency: $vm.leftCurrency, bottomCurrency: $vm.rightCurrency)
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
                    CCText.subHeadline(currency.name)
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
                    CCText.subHeadline(currency.name)
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
