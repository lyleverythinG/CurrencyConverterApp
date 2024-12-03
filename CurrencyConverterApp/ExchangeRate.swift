import SwiftUI

struct ExchangeRate: View {
    let leftImage: ImageResource
    let text: String
    let rightImage: ImageResource
    
    var body: some View {
        HStack  { // 4x
            Image(leftImage)
                .resizable()
                .scaledToFit()
                .frame(height:33)
            CCText.defaultText(text)
            Image(rightImage)
                .resizable()
                .scaledToFit()
                .frame(height:33)
            
        }
    }
}

