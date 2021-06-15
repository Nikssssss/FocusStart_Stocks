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
    
    func changeState(to state: StockCellPresenterState)
}

protocol IStockCellPresenterState: class {
    func getNumberOfRows() -> Int
    func loadStocks(completion: @escaping ((Error?) -> Void))
    func loadStocks(using searchText: String, completion: @escaping ((Error?) -> Void))
    func titleForHeader() -> String
    func getStock(at row: Int) -> PreviewStockDto?
    func loadLogoImageData(using stock: PreviewStockDto, completion: @escaping ((Data?) -> Void))
    func refreshStocks(completion: @escaping ((Error?) -> Void))
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
        return 70
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
        cell.setPrice("$" + String(price))
        var stringDelta = String(format: "%.2f", delta)
        if delta > 0 {
            stringDelta.insert("+", at: stringDelta.startIndex)
        }
        cell.setDelta(stringDelta)
        let greenDeltaColor = UIColor(red: 35 / 255.0, green: 175 / 255.0, blue: 86 / 255.0, alpha: 1.0)
        let deltaColor = delta >= 0 ? greenDeltaColor : UIColor.red
        cell.setDeltaColor(deltaColor)
    }
    
    private func setFavouriteImage(to cell: IStockTableCell, isFavourite: Bool) {
        let imageName = "star.fill"
        guard let image = UIImage(systemName: imageName) else { return }
        let yellowColor = UIColor(red: 255 / 255.0, green: 202 / 255.0, blue: 28 / 255.0, alpha: 1.0)
        let imageColor = isFavourite ? yellowColor : UIColor.lightGray
        let coloredImage = image.withTintColor(imageColor, renderingMode: .alwaysOriginal)
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
