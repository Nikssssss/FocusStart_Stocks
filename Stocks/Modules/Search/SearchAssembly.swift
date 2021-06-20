//
//  SearchAssembly.swift
//  Stocks
//
//  Created by Никита Гусев on 08.06.2021.
//

import Foundation

final class SearchAssembly {
    static func makeModule() -> ModuleNavigationItem? {
        let container = DependencyContainer.shared.container
        guard let storageManager = container.resolve(IStorageManager.self),
              let networkManager = container.resolve(INetworkManager.self),
              let navigator = container.resolve(INavigator.self),
              let dataCacheManager = container.resolve(IDataCacheManager.self)
        else { return nil }
        
        let searchUI = SearchUI()
        
        let stockCellPresenter = StockCellPresenter(storageManager: storageManager,
                                                    networkManager: networkManager,
                                                    dataCacheManager: dataCacheManager)
        let presenter = SearchPresenter(searchUI: searchUI,
                                        stockCellPresenter: stockCellPresenter,
                                        navigator: navigator)
        
        searchUI.setPresenter(presenter)
        
        let moduleNavigationItem = ModuleNavigationItem(viewController: searchUI)
        return moduleNavigationItem
    }
}
