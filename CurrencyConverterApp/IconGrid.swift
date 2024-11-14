
import SwiftUI

struct IconGrid: View {
    @Binding var currency: Currency
    
    var body: some View {
        LazyVGrid(columns:[GridItem(), GridItem(), GridItem()]) {
            ForEach (Currency.allCases) { currency in
                if self.currency == currency {
                    CurrencyIcon(currencyImage: currency.image, currencyName: currency.name)
                        .shadow(color:.black, radius: 10)
                        .overlay {
                            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                                .stroke(lineWidth: 3)
                                .opacity(0.5)
                        }
                }
                else {
                    CurrencyIcon(currencyImage: currency.image, currencyName: currency.name)
                        .shadow(color:.black, radius: 10)
                        .onTapGesture {
                            self.currency = currency
                        }
                }
                   
            }
        }
    }
}

#Preview {
    IconGrid(currency: .constant(.usdCurrency))
}
