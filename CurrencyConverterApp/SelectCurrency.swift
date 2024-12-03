
import SwiftUI

struct SelectCurrency: View {
    @Environment(\.dismiss) var dismiss
    @Binding var topCurrency : Currency
    @Binding var bottomCurrency : Currency
    
    var body: some View {
        ZStack {
            Image(.parchment)
                .resizable()
                .ignoresSafeArea()
                .background(.brown)
            VStack {
                CCText.defaultText("Select the currency you are starting with:")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                IconGrid(currency: $topCurrency)
                CCText.defaultText("Select the currency you would like to convert to:")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                IconGrid(currency: $bottomCurrency)
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.brown)
                .font(.largeTitle)
                .padding()
                .foregroundStyle(.white)
            }
            .multilineTextAlignment(.center)
            .padding()
        }
    }
}

#Preview {
    SelectCurrency(topCurrency: .constant(.usdCurrency), bottomCurrency: .constant(.phpCurrency))
}
