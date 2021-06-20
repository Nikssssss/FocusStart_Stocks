//
//  IStockStorage.swift
//  Stocks
//
//  Created by Никита Гусев on 20.06.2021.
//

import Foundation

protocol IStockStorage: class {
    var retrievedStocks: [PreviewStockDto] { get }
    
    func loadDefaultStocks()
    func loadRecentSearchedStocks()
    func loadFavouriteStocks()
    func addDefaultStock(stockDto: PreviewStockDto, to user: UserStorageDto)
    func addRecentSearchedStock(stockDto: PreviewStockDto)
    func addFavouriteStock(stockDto: PreviewStockDto)
    func removeStockFromFavourites(stockDto: PreviewStockDto)
    func isFavouriteStock(stockDto: PreviewStockDto) -> Bool
    func updateStockQuote(of ticker: String, price: Double, delta: Double)
    func checkIfStockFavourite(ticker: String) -> Bool
}
