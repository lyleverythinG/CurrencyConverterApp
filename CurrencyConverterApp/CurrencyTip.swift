//
//  CurrencyTip.swift
//  CurrencyConverter
//
//  Created by Lyle Dane Carcedo on 10/23/24.
//

import Foundation
import TipKit

struct CurrencyTip: Tip {
    var title = Text("Change Currency")
    var message: Text? = Text("You can tap left or right currency to bring up the Select Currency screen.")
}

