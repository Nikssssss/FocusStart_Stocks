//
//  FavouriteStockCellPresenterState.swift
//  Stocks
//
//  Created by Никита Гусев on 15.06.2021.
//

import Foundation

final class FavouriteStockCellPresenterState: IStockCellPresenterState {
    private let storageManager: IStorageManager
    private let networkManager: INetworkManager
    private let dataCacheManager: IDataCacheManager
    
    init(storageManager: IStorageManager, networkManager: INetworkManager, dataCacheManager: IDataCacheManager) {
        self.storageManager = storageManager
        self.networkManager = networkManager
        self.dataCacheManager = dataCacheManager
    }
    
    func getNumberOfRows() -> Int {
        self.storageManager.retrievedStocks.count
    }
    
    func titleForHeader() -> String {
        return String()
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
    
    func loadStocks(completion: @escaping ((Error?) -> Void)) {
        self.storageManager.loadFavouriteStocks()
        completion(nil)
    }
}