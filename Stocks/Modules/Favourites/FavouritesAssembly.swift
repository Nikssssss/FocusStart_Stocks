//
//  FavouritesAssembly.swift
//  Stocks
//
//  Created by Никита Гусев on 15.06.2021.
//

import Foundation

final class FavouritesAssembly {
    static func makeModule() -> ModuleNavigationItem? {
        let container = DependencyContainer.shared.container
        guard let storageManager = container.resolve(IStorageManager.self),
              let networkManager = container.resolve(INetworkManager.self),
              let navigator = container.resolve(INavigator.self),
              let dataCacheManager = container.resolve(IDataCacheManager.self)
        else { return nil }
        
        let favouritesUI = FavouritesUI()
        
        let stockCellPresenter = StockCellPresenter(storageManager: storageManager,
                                                    networkManager: networkManager,
                                                    dataCacheManager: dataCacheManager)
        let presenter = FavouritesPresenter(favouritesUI: favouritesUI,
                                            stockCellPresenter: stockCellPresenter,
                                            navigator: navigator)
        
        favouritesUI.setPresenter(presenter)
        
        let moduleNavigationItem = ModuleNavigationItem(viewController: favouritesUI)
        return moduleNavigationItem
    }
}
