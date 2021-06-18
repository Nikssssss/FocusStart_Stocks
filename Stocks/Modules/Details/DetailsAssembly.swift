//
//  DetailsAssembly.swift
//  Stocks
//
//  Created by Никита Гусев on 17.06.2021.
//

import Foundation
import class UIKit.UIApplication

final class DetailsAssembly {
    static func makeModule(with previewStock: PreviewStockDto) -> ModuleNavigationItem? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let container = appDelegate?.container,
              let networkManager = container.resolve(INetworkManager.self),
              let navigator = container.resolve(INavigator.self)
        else { return nil }
        let detailsUI = DetailsUI()
        
        let chartsPresenter = ChartsPresenter(networkManager: networkManager,
                                              ticker: previewStock.ticker)
        let presenter = DetailsPresenter(detailsUI: detailsUI,
                                         previewStock: previewStock,
                                         navigator: navigator,
                                         chartsPresenter: chartsPresenter)
        detailsUI.setPresenter(presenter)
        
        let moduleNavigationItem = ModuleNavigationItem(viewController: detailsUI)
        return moduleNavigationItem
    }
}
