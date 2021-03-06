//
//  SearchStockCellPresenterState.swift
//  Stocks
//
//  Created by Никита Гусев on 12.06.2021.
//

import Foundation

final class SearchStockCellPresenterState: IStockCellPresenterState {
    private let storageManager: IStorageManager
    private let networkManager: INetworkManager
    
    init(storageManager: IStorageManager, networkManager: INetworkManager) {
        self.storageManager = storageManager
        self.networkManager = networkManager
    }
    
    func getNumberOfRows() -> Int {
        return self.networkManager.downloadedStocks.count
    }
    
    func titleForHeader() -> String {
        return SearchConstants.searchStateHeaderTitle
    }
    
    func getStock(at row: Int) -> PreviewStockDto? {
        let downloadedStocks = self.networkManager.downloadedStocks
        guard row >= 0 && row < downloadedStocks.count else { return nil }
        let downloadedStock = downloadedStocks[row]
        let ticker = downloadedStock.companyProfile.ticker
        let quote = downloadedStock.quote
        let delta = DeltaCounter.countDelta(openPrice: quote.openPrice,
                                            currentPrice: quote.currentPrice)
        let isFavourite = storageManager.checkIfStockFavourite(ticker: ticker)
        let previewStockDto = StockMapper.downloadedToPreview(downloadedStock,
                                                              delta: delta,
                                                              isFavourite: isFavourite)
        return previewStockDto
    }
    
    func loadStocks(using searchText: String, completion: @escaping ((Error?) -> Void)) {
        self.networkManager.cancelAllLoadingTasks()
        self.networkManager.removeAllDownloadedStocks()
        self.networkManager.loadStocksTickers(by: searchText) { tickersResult in
            self.handleFoundedTickersResult(tickersResult, completion: completion)
        }
    }
    
    func loadStocks(completion: @escaping ((Error?) -> Void)) {
    }
    
    func loadLogoImageData(using stock: PreviewStockDto, completion: @escaping ((Data?) -> Void)) {
        guard let url = URL(string: stock.logoUrl) else { completion(nil); return }
        self.networkManager.downloadData(from: url, completion: completion)
    }

    func refreshStocks(completion: @escaping ((Error?) -> Void)) {
        let tickers = self.networkManager.downloadedStocks.map({ $0.companyProfile.ticker })
        self.networkManager.loadAllStocks(with: tickers) { downloadedStocksResult in
            switch downloadedStocksResult {
            case .failure(let error):
                completion(error)
            case .success(_):
                completion(nil)
            }
        }
    }
    
    func stockPressed(stock: PreviewStockDto) {
        self.storageManager.addRecentSearchedStock(stockDto: stock)
    }
    
    private func handleFoundedTickersResult(_ result: Result<[TickerDto], NetworkError>,
                                    completion: @escaping ((Error?) -> Void)) {
        switch result {
        case .failure(let error):
            self.networkManager.removeAllDownloadedStocks()
            completion(error)
        case .success(let tickersDto):
            self.networkManager.loadAllStocks(with: tickersDto.map { $0.symbol }) { downloadedStocksResult in
                self.handleDownloadedStocksResult(downloadedStocksResult, completion: completion)
            }
        }
    }
    
    private func handleDownloadedStocksResult(_ result: Result<[DownloadedStockDto], NetworkError>,
                                              completion: @escaping ((Error?) -> Void)) {
        switch result {
        case .failure(let error):
            self.networkManager.removeAllDownloadedStocks()
            completion(error)
        case .success(_):
            completion(nil)
        }
    }
}
