import SwiftUI

struct ExchangeRate: View {
    let leftImage: ImageResource
    let text: String
    let rightImage: ImageResource
    
    var body: some View {
        HStack  {
            ExchangeRateImg(image: leftImage)
            CCText.defaultText(text)
            ExchangeRateImg(image: rightImage)
        }
    }
    
  private struct ExchangeRateImg: View {
        let image: ImageResource
        
        var body: some View {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(height:33)
        }
    }
}
