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
    
    init(storageManager: IStorageManager) {
        self.storageManager = storageManager
    }
    
    func getNumberOfRows() -> Int {
        return self.storageManager.retrievedStocks.count
    }
    
    func loadStocks(completion: @escaping ((Error?) -> Void)) {
        DispatchQueue.global(qos: .utility).async {
            self.storageManager.loadRecentSearchedStocks()
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    func titleForHeader() -> String {
        return "Недавние поиски"
    }
    
    func getStock(at row: Int) -> PreviewStockDto? {
        let retrievedStocks = self.storageManager.retrievedStocks
        guard row >= 0 && row < retrievedStocks.count else { return nil }
        return retrievedStocks[row]
    }
}
