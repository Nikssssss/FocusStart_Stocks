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

enum StockCellPresenterState {
    case defaultStocks, recentStocks, searchedStocks
}

protocol IStockCellPresenter: class {
    func getNumberOfRows() -> Int
    func getHeightForRow(at indexPath: IndexPath) -> CGFloat
    func cellWillAppear(_ cell: IStockTableCell, at indexPath: IndexPath)
    func loadStocks(completion: @escaping ((Error?) -> Void))
    func loadStocks(using searchText: String, completion: @escaping ((Error?) -> Void))
    func titleForHeader() -> String
    
    func changeState(to state: StockCellPresenterState)
}

protocol IStockCellPresenterState: class {
    func getNumberOfRows() -> Int
    func loadStocks(completion: @escaping ((Error?) -> Void))
    func loadStocks(using searchText: String, completion: @escaping ((Error?) -> Void))
    func titleForHeader() -> String
    func getStock(at row: Int) -> PreviewStockDto?
}

extension IStockCellPresenterState {
    func loadStocks(completion: @escaping ((Error?) -> Void)) {
        completion(nil)
    }
    
    func loadStocks(using searchText: String, completion: @escaping ((Error?) -> Void)) {
        completion(nil)
    }
}

final class StockCellPresenter: IStockCellPresenter {
    private var stockCellPresenterState: IStockCellPresenterState
    private let storageManager: IStorageManager
    private let networkManager: INetworkManager
    
    init(storageManager: IStorageManager,
         networkManager: INetworkManager) {
        self.stockCellPresenterState = DefaultStockCellPresenterState(storageManager: storageManager)
        self.storageManager = storageManager
        self.networkManager = networkManager
    }
    
    func getNumberOfRows() -> Int {
        self.stockCellPresenterState.getNumberOfRows()
    }
    
    func getHeightForRow(at indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func cellWillAppear(_ cell: IStockTableCell, at indexPath: IndexPath) {
        guard let stock = self.stockCellPresenterState.getStock(at: indexPath.row)
        else { return }
        self.configureCell(cell, using: stock, at: indexPath)
    }
    
    func loadStocks(completion: @escaping ((Error?) -> Void)) {
        self.stockCellPresenterState.loadStocks(completion: completion)
    }
    
    func loadStocks(using searchText: String, completion: @escaping ((Error?) -> Void)) {
        self.stockCellPresenterState.loadStocks(using: searchText, completion: completion)
    }
    
    func titleForHeader() -> String {
        return self.stockCellPresenterState.titleForHeader()
    }
    
    func changeState(to state: StockCellPresenterState) {
        switch state {
        case .defaultStocks:
            self.stockCellPresenterState = DefaultStockCellPresenterState(storageManager: storageManager)
        case .recentStocks:
            self.stockCellPresenterState = RecentStockCellPresenterState(storageManager: storageManager)
        case .searchedStocks:
            self.stockCellPresenterState = SearchStockCellPresenterState(storageManager: storageManager,
                                                                         networkManager: networkManager)
        }
    }
    
    private func configureCell(_ cell: IStockTableCell,
                               using stock: PreviewStockDto,
                               at indexPath: IndexPath) {
        self.setLogoImage(to: cell, logoUrl: stock.logoUrl)
        self.setCompanyInfo(to: cell, ticker: stock.ticker, companyName: stock.companyName)
        self.setQuoteInfo(to: cell, price: stock.price, delta: stock.delta)
        self.setFavouriteImage(to: cell, isFavourite: stock.isFavourite)
        self.setBackgroundColor(to: cell, at: indexPath)
    }
    
    private func setLogoImage(to cell: IStockTableCell, logoUrl: String) {
        DispatchQueue.global(qos: .utility).async {
            guard let imageUrl = URL(string: logoUrl),
                  let imageData = try? Data(contentsOf: imageUrl),
                  let image = UIImage(data: imageData)
            else {
                DispatchQueue.main.async {
                    cell.setLogoImage(UIImage())
                }
                return
            }
            DispatchQueue.main.async {
                cell.setLogoImage(image)
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
    
    private func setFavouriteImage(to cell: IStockTableCell, isFavourite: Bool) {
        let imageName = isFavourite ? "star.fill" : "star"
        guard let image = UIImage(systemName: imageName) else { return }
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
