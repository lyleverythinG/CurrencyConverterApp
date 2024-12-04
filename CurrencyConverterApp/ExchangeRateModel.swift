//
//  ExchangeRateModel.swift
//  CurrencyConverterApp
//
//  Created by Lyle Dane Carcedo on 12/4/24.
//
import SwiftUI

struct ExchangeRateModel: Identifiable {
    let id = UUID()
    let leftImage: ImageResource
    let text: String
    let rightImage: ImageResource
}

