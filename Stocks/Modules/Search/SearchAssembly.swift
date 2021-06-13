//
//  SearchAssembly.swift
//  Stocks
//
//  Created by Никита Гусев on 08.06.2021.
//

import Foundation
import class UIKit.UIApplication

final class SearchAssembly {
    static func makeModule() -> ModuleNavigationItem? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let container = appDelegate?.container,
              let storageManager = container.resolve(IStorageManager.self),
              let networkManager = container.resolve(INetworkManager.self)
        else { return nil }
        
        let searchUI = SearchUI()
        
        let stockCellPresenter = StockCellPresenter(storageManager: storageManager,
                                                    networkManager: networkManager)
        let presenter = SearchPresenter(searchUI: searchUI, stockCellPresenter: stockCellPresenter)
        
        searchUI.setPresenter(presenter)
        
        let moduleNavigationItem = ModuleNavigationItem(viewController: searchUI, navigationItemTag: .search)
        return moduleNavigationItem
    }
}
