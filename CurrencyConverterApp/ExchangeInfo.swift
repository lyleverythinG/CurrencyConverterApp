import SwiftUI

struct ExchangeInfo: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = ExchangeInfoViewModel()
    
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
                
                if vm.isLoading {
                    ProgressView("Loading exchange rates...")
                } else {
                    ForEach(vm.exchangeRates) { rate in
                        ExchangeRate(
                            leftImage: rate.leftImage,
                            text: rate.text,
                            rightImage: rate.rightImage
                        )
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
        .onAppear {
            vm.fetchExchangeRatesInfo()
        }
    }
}

#Preview {
    ExchangeInfo()
}
