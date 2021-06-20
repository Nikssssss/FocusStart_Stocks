//
//  ConfigurationReader.swift
//  Stocks
//
//  Created by Никита Гусев on 09.06.2021.
//

import Foundation

protocol IConfigurationReader: class {
    func getAllDefaultStocksTickers() -> [String]
}

final class ConfigurationReader: IConfigurationReader {
    func getAllDefaultStocksTickers() -> [String] {
        guard let url = Bundle.main.url(forResource: "DefaultStocks", withExtension: "plist"),
              let propertyDictionary = NSDictionary(contentsOf: url),
              let stocksTickersArray = propertyDictionary.value(forKey: "defaultStocksTickers") as? [String]
        else { return [] }
        return stocksTickersArray
    }
}
