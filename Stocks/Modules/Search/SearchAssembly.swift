//
//  SearchAssembly.swift
//  Stocks
//
//  Created by Никита Гусев on 08.06.2021.
//

import Foundation

final class SearchAssembly {
    static func makeModule() -> ModuleNavigationItem {
        let searchUI = SearchUI()
        
        let stockCellPresenterState = DefaultStockCellPresenterState(configurationReader: ConfigurationReader(),
                                                                            networkManager: NetworkManager())
        let stockCellPresenter = StockCellPresenter(stockCellPresenterState: stockCellPresenterState)
        let presenter = SearchPresenter(searchUI: searchUI, stockCellPresenter: stockCellPresenter)
        
        searchUI.setPresenter(presenter)
        
        let moduleNavigationItem = ModuleNavigationItem(viewController: searchUI, tabItemTag: .search)
        return moduleNavigationItem
    }
}
