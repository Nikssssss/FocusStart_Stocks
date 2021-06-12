//
//  StockCellPresenter.swift
//  Stocks
//
//  Created by Никита Гусев on 09.06.2021.
//

import Foundation
import struct CoreGraphics.CGFloat
import class UIKit.UIImage
import class UIKit.UIColor

protocol IStockCellPresenter: class {
    func getNumberOfRows() -> Int
    func getHeightForRow(at indexPath: IndexPath) -> CGFloat
    func cellWillAppear(_ cell: IStockTableCell, at indexPath: IndexPath)
    func loadStocks(completion: @escaping (() -> Void))
    func titleForHeader() -> String
    
    func changeState(to state: IStockCellPresenterState)
}

protocol IStockCellPresenterState: class {
    func getNumberOfRows() -> Int
    func getHeightForRow(at indexPath: IndexPath) -> CGFloat
    func cellWillAppear(_ cell: IStockTableCell, at indexPath: IndexPath)
    func loadStocks(completion: @escaping (() -> Void))
    func titleForHeader() -> String
}

final class StockCellPresenter: IStockCellPresenter {
    private var stockCellPresenterState: IStockCellPresenterState
    
    init(stockCellPresenterState: IStockCellPresenterState) {
        self.stockCellPresenterState = stockCellPresenterState
    }
    
    func getNumberOfRows() -> Int {
        self.stockCellPresenterState.getNumberOfRows()
    }
    
    func getHeightForRow(at indexPath: IndexPath) -> CGFloat {
        self.stockCellPresenterState.getHeightForRow(at: indexPath)
    }
    
    func cellWillAppear(_ cell: IStockTableCell, at indexPath: IndexPath) {
        self.stockCellPresenterState.cellWillAppear(cell, at: indexPath)
    }
    
    func loadStocks(completion: @escaping (() -> Void)) {
        self.stockCellPresenterState.loadStocks(completion: completion)
    }
    
    func titleForHeader() -> String {
        return self.stockCellPresenterState.titleForHeader()
    }
    
    func changeState(to state: IStockCellPresenterState) {
        self.stockCellPresenterState = state
    }
}

final class DefaultStockCellPresenterState: IStockCellPresenterState {
    private let storageManager: IStorageManager
    
    init(storageManager: IStorageManager) {
        self.storageManager = storageManager
    }
    
    func getNumberOfRows() -> Int {
        return self.storageManager.retrievedStocks.count
    }
    
    func getHeightForRow(at indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func cellWillAppear(_ cell: IStockTableCell, at indexPath: IndexPath) {
        let stock = self.storageManager.retrievedStocks[indexPath.row]
        self.configureCell(cell, using: stock, at: indexPath)
    }
    
    func loadStocks(completion: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .utility).async {
            self.storageManager.loadDefaultStocks()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func titleForHeader() -> String {
        return "Популярные запросы"
    }
    
    private func configureCell(_ cell: IStockTableCell,
                               using stock: PreviewStockDto,
                               at indexPath: IndexPath) {
        self.setLogoImage(to: cell, logoUrl: stock.logoUrl)
        self.setCompanyInfo(to: cell, ticker: stock.ticker, companyName: stock.companyName)
        self.setQuoteInfo(to: cell, price: stock.price, delta: stock.delta)
        self.setFavouriteImage(to: cell)
        self.setBackgroundColor(to: cell, at: indexPath)
    }
    
    private func setLogoImage(to cell: IStockTableCell, logoUrl: String) {
        DispatchQueue.global(qos: .utility).async {
            guard let imageUrl = URL(string: logoUrl) else { return }
            if let imageData = try? Data(contentsOf: imageUrl),
               let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    cell.setLogoImage(image)
                }
            }
        }
    }
    
    private func setCompanyInfo(to cell: IStockTableCell, ticker: String, companyName: String) {
        cell.setTicker(ticker)
        cell.setCompanyName(companyName)
    }
    
    private func setQuoteInfo(to cell: IStockTableCell, price: Double, delta: Double) {
        cell.setPrice("$" + String(price))
        var stringDelta = String(format: "%.2f", delta)
        if delta > 0 {
            stringDelta.insert("+", at: stringDelta.startIndex)
        }
        cell.setDelta(stringDelta, increased: delta >= 0)
    }
    
    private func setFavouriteImage(to cell: IStockTableCell) {
        guard let image = UIImage(systemName: "star") else { return }
        let coloredImage = image.withTintColor(.orange, renderingMode: .alwaysOriginal)
        cell.setFavouriteButtonImage(coloredImage)
    }
    
    private func setBackgroundColor(to cell: IStockTableCell, at indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.setBackgroundColor(UIColor(red: 240.0 / 255,
                                            green: 240.0 / 255,
                                            blue: 240.0 / 255,
                                            alpha: 1.0))
        } else {
            cell.setBackgroundColor(.white)
        }
    }
}
