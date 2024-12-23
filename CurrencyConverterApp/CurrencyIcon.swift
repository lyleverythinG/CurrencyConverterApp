import SwiftUI

struct CurrencyIcon: View {
    let currencyImage: ImageResource
    let currencyName: String
    var body: some View {
        ZStack(alignment:.bottom) {
            Image(currencyImage)
                .resizable()
                .scaledToFit()
            CCText.caption(currencyName)
                .padding(3)
                .frame(maxWidth:.infinity)
                .background(.brown.opacity(0.75))
        }
        .padding(3)
        .frame(width:100, height: 100)
        .background(.brown)
        .clipShape(.rect(cornerRadius:25))
    }
}

#Preview {
    CurrencyIcon(currencyImage: .usd, currencyName: "US Dollar")
}
