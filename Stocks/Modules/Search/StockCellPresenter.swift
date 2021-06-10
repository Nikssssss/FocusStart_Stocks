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
    private let configurationReader: IConfigurationReader
    private let networkManager: INetworkManager
    
    init(configurationReader: IConfigurationReader, networkManager: INetworkManager) {
        self.configurationReader = configurationReader
        self.networkManager = networkManager
    }
    
    func getNumberOfRows() -> Int {
        return self.networkManager.downloadedStocks.count
    }
    
    func getHeightForRow(at indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func cellWillAppear(_ cell: IStockTableCell, at indexPath: IndexPath) {
        let stock = self.networkManager.downloadedStocks[indexPath.row]
        let companyProfile = stock.companyProfile
        let quote = stock.quote
        self.setCompanyProfileInfo(to: cell, companyProfile: companyProfile)
        self.setQuoteInfo(to: cell, quote: quote)
        self.setFavouriteImage(to: cell)
        self.setBackgroundColor(to: cell, at: indexPath)
    }
    
    func loadStocks(completion: @escaping (() -> Void)) {
        let defaultStocksTickers = configurationReader.getAllDefaultStocksTickers()
        self.networkManager.loadAllStocks(with: defaultStocksTickers, completion: completion)
    }
    
    func titleForHeader() -> String {
        return "Популярные запросы"
    }
    
    private func setCompanyProfileInfo(to cell: IStockTableCell, companyProfile: CompanyProfileDto) {
        cell.setTicker(companyProfile.ticker)
        cell.setCompanyName(companyProfile.name)
        DispatchQueue.global(qos: .utility).async {
            guard let imageUrl = URL(string: companyProfile.logo) else { return }
            if let imageData = try? Data(contentsOf: imageUrl),
               let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    cell.setLogoImage(image)
                }
            }
        }
    }
    
    private func setQuoteInfo(to cell: IStockTableCell, quote: QuoteDto) {
        cell.setPrice("$" + String(quote.currentPrice))
        let delta = DeltaCounter.countDelta(openPrice: quote.openPrice,
                                            currentPrice: quote.currentPrice)
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
