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
    case defaultStocks, recentStocks, searchedStocks, favouriteStocks
}

protocol IStockCellPresenter: class {
    func getNumberOfRows() -> Int
    func getHeightForRow(at indexPath: IndexPath) -> CGFloat
    func cellWillAppear(_ cell: IStockTableCell, at indexPath: IndexPath,
                        favouriteButtonHandler: @escaping (() -> Void))
    func loadStocks(completion: @escaping ((Error?) -> Void))
    func loadStocks(using searchText: String, completion: @escaping ((Error?) -> Void))
    func titleForHeader() -> String
    func didSelectRow(at indexPath: IndexPath, completion: ((PreviewStockDto?) -> Void))
    func refreshStocks(completion: @escaping ((Error?) -> Void))
    func stockPressed(stock: PreviewStockDto)
    
    func changeState(to state: StockCellPresenterState)
}

final class StockCellPresenter: IStockCellPresenter {
    private var stockCellPresenterState: IStockCellPresenterState
    private let storageManager: IStorageManager
    private let networkManager: INetworkManager
    private let dataCacheManager: IDataCacheManager
    
    init(storageManager: IStorageManager,
         networkManager: INetworkManager,
         dataCacheManager: IDataCacheManager) {
        self.stockCellPresenterState = DefaultStockCellPresenterState(storageManager: storageManager,
                                                                      networkManager: networkManager,
                                                                      dataCacheManager: dataCacheManager)
        self.storageManager = storageManager
        self.networkManager = networkManager
        self.dataCacheManager = dataCacheManager
    }
    
    func getNumberOfRows() -> Int {
        self.stockCellPresenterState.getNumberOfRows()
    }
    
    func getHeightForRow(at indexPath: IndexPath) -> CGFloat {
        return PreviewConstants.cellHeight
    }
    
    func cellWillAppear(_ cell: IStockTableCell, at indexPath: IndexPath,
                        favouriteButtonHandler: @escaping (() -> Void)) {
        guard let stock = self.stockCellPresenterState.getStock(at: indexPath.row)
        else { return }
        self.configureCell(cell, using: stock, at: indexPath,
                           favouriteButtonHandler: favouriteButtonHandler)
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
    
    func didSelectRow(at indexPath: IndexPath, completion: ((PreviewStockDto?) -> Void)) {
        let previewStock = self.stockCellPresenterState.getStock(at: indexPath.row)
        completion(previewStock)
    }
    
    func refreshStocks(completion: @escaping ((Error?) -> Void)) {
        self.stockCellPresenterState.refreshStocks(completion: completion)
    }
    
    func stockPressed(stock: PreviewStockDto) {
        self.stockCellPresenterState.stockPressed(stock: stock)
    }
    
    func changeState(to state: StockCellPresenterState) {
        switch state {
        case .defaultStocks:
            self.stockCellPresenterState = DefaultStockCellPresenterState(storageManager: storageManager,
                                                                          networkManager: networkManager,
                                                                          dataCacheManager: dataCacheManager)
        case .recentStocks:
            self.stockCellPresenterState = RecentStockCellPresenterState(storageManager: storageManager,
                                                                         networkManager: networkManager,
                                                                         dataCacheManager: dataCacheManager)
        case .searchedStocks:
            self.stockCellPresenterState = SearchStockCellPresenterState(storageManager: storageManager,
                                                                         networkManager: networkManager)
        case .favouriteStocks:
            self.stockCellPresenterState = FavouriteStockCellPresenterState(storageManager: storageManager,
                                                                            networkManager: networkManager,
                                                                            dataCacheManager: dataCacheManager)
        }
    }
    
    private func configureCell(_ cell: IStockTableCell,
                               using stock: PreviewStockDto,
                               at indexPath: IndexPath,
                               favouriteButtonHandler: @escaping (() -> Void)) {
        self.setLogoImage(to: cell, stock: stock)
        self.setCompanyInfo(to: cell, ticker: stock.ticker, companyName: stock.companyName)
        self.setQuoteInfo(to: cell, price: stock.price, delta: stock.delta)
        self.setFavouriteImage(to: cell, isFavourite: stock.isFavourite)
        self.setBackgroundColor(to: cell, at: indexPath)
        self.setFavouriteButtonTapHandler(to: cell, at: indexPath,
                                          favouriteButtonHandler: favouriteButtonHandler)
    }
    
    private func setLogoImage(to cell: IStockTableCell, stock: PreviewStockDto) {
        self.stockCellPresenterState.loadLogoImageData(using: stock) { imageData in
            guard let imageData = imageData,
                  let image = UIImage(data: imageData)
            else { self.setDefaultImage(to: cell); return }
            DispatchQueue.main.async {
                cell.setLogoImage(image)
            }
        }
    }
    
    func setDefaultImage(to cell: IStockTableCell) {
        DispatchQueue.main.async {
            cell.setLogoImage(UIImage())
        }
    }
    
    private func setCompanyInfo(to cell: IStockTableCell, ticker: String, companyName: String) {
        cell.setTicker(ticker)
        cell.setCompanyName(companyName)
    }
    
    private func setQuoteInfo(to cell: IStockTableCell, price: Double, delta: Double) {
        cell.setPrice(PreviewConstants.dollarCurrency + String(format: "%.2f", price))
        var stringDelta = String(format: "%.2f", delta)
        if delta > 0 {
            stringDelta.insert(contentsOf: PreviewConstants.positiveChange,
                               at: stringDelta.startIndex)
        }
        cell.setDelta(stringDelta)
        let positiveDeltaColor = PreviewConstants.cellDeltaPositiveColor
        let negativeDeltaColor = PreviewConstants.cellNegativeDeltaColor
        let deltaColor = delta >= 0 ? positiveDeltaColor : negativeDeltaColor
        cell.setDeltaColor(deltaColor)
    }
    
    private func setFavouriteImage(to cell: IStockTableCell, isFavourite: Bool) {
        let imageName = PreviewConstants.cellFavouriteImageName
        guard let image = UIImage(systemName: imageName) else { return }
        let isFavouriteColor = PreviewConstants.cellIsFavouriteColor
        let isNotFavouriteColor = PreviewConstants.cellIsNotFavouriteColor
        let imageColor = isFavourite ? isFavouriteColor : isNotFavouriteColor
        let coloredImage = image.withTintColor(imageColor, renderingMode: .alwaysOriginal)
        cell.setFavouriteButtonImage(coloredImage)
    }
    
    private func setBackgroundColor(to cell: IStockTableCell, at indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.setBackgroundColor(PreviewConstants.cellEvenBackgroundColor)
        } else {
            cell.setBackgroundColor(PreviewConstants.cellOddBackgroundColor)
        }
    }
    
    private func setFavouriteButtonTapHandler(to cell: IStockTableCell,
                                              at indexPath: IndexPath,
                                              favouriteButtonHandler: @escaping (() -> Void)) {
        cell.favouriteButtonTapHandler = { [weak self] in
            guard let self = self,
                  let previewStock = self.stockCellPresenterState.getStock(at: indexPath.row)
            else { return }
            if self.storageManager.isFavouriteStock(stockDto: previewStock) {
                self.storageManager.removeStockFromFavourites(stockDto: previewStock)
            } else {
                self.storageManager.addFavouriteStock(stockDto: previewStock)
            }
            favouriteButtonHandler()
        }
    }
}
