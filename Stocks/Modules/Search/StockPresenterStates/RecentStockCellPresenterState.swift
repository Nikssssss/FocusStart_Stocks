//
//  RecentStockCellPresenterState.swift
//  Stocks
//
//  Created by Никита Гусев on 12.06.2021.
//

import Foundation
import struct CoreGraphics.CGFloat

final class RecentStockCellPresenterState: IStockCellPresenterState {
    private let storageManager: IStorageManager
    private let networkManager: INetworkManager
    private let dataCacheManager: IDataCacheManager
    
    init(storageManager: IStorageManager, networkManager: INetworkManager, dataCacheManager: IDataCacheManager) {
        self.storageManager = storageManager
        self.networkManager = networkManager
        self.dataCacheManager = dataCacheManager
    }
    
    func getNumberOfRows() -> Int {
        return self.storageManager.retrievedStocks.count
    }
    
    func loadStocks(completion: @escaping ((Error?) -> Void)) {
        self.storageManager.loadRecentSearchedStocks()
        completion(nil)
    }
    
    func loadStocks(using searchText: String, completion: @escaping ((Error?) -> Void)) {
    }
    
    func titleForHeader() -> String {
        return SearchConstants.recentStateHeaderTitle
    }
    
    func getStock(at row: Int) -> PreviewStockDto? {
        let retrievedStocks = self.storageManager.retrievedStocks
        guard row >= 0 && row < retrievedStocks.count else { return nil }
        return retrievedStocks[row]
    }
    
    func loadLogoImageData(using stock: PreviewStockDto, completion: @escaping ((Data?) -> Void)) {
        let key = stock.ticker
        if let data = self.dataCacheManager.getData(from: key) {
            completion(data)
            return
        }
        guard let url = URL(string: stock.logoUrl) else { completion(nil); return }
        self.networkManager.downloadData(from: url) { data in
            completion(data)
            if let data = data {
                self.dataCacheManager.saveData(data, for: key)
            }
        }
    }
    
    func refreshStocks(completion: @escaping ((Error?) -> Void)) {
        let tickers = self.storageManager.retrievedStocks.map({ $0.ticker })
        self.networkManager.loadQuotes(for: tickers) { quoteInfosResult in
            switch quoteInfosResult {
            case .failure(let error):
                completion(error)
            case .success(let refreshQuoteInfos):
                refreshQuoteInfos.forEach { quoteInfo in
                    let quote = quoteInfo.quote
                    let delta = DeltaCounter.countDelta(openPrice: quote.openPrice,
                                                        currentPrice: quote.currentPrice)
                    self.storageManager.updateStockQuote(of: quoteInfo.ticker,
                                                         price: quote.currentPrice,
                                                         delta: delta)
                }
                self.storageManager.loadRecentSearchedStocks()
                completion(nil)
            }
        }
    }
    
    func stockPressed(stock: PreviewStockDto) {
    }
}
