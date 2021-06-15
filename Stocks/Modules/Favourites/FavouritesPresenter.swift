//
//  FavouritesPresenter.swift
//  Stocks
//
//  Created by Никита Гусев on 15.06.2021.
//

import Foundation

protocol IFavouritesPresenter: class {
    func loadView()
    func viewDidLoad()
    func viewDidAppear()
}

final class FavouritesPresenter: IFavouritesPresenter {
    private weak var favouritesUI: IFavouritesUI?
    private let stockCellPresenter: StockCellPresenter
    private let navigator: INavigator
    
    init(favouritesUI: IFavouritesUI, stockCellPresenter: StockCellPresenter, navigator: INavigator) {
        self.favouritesUI = favouritesUI
        self.stockCellPresenter = stockCellPresenter
        self.navigator = navigator
    }
    
    func loadView() {
        self.favouritesUI?.replaceScreenView()
    }
    
    func viewDidLoad() {
        self.favouritesUI?.configureUI()
        self.hookUI()
        self.stockCellPresenter.changeState(to: .favouriteStocks)
    }
    
    func viewDidAppear() {
        self.handleStocksLoading()
    }
}

private extension FavouritesPresenter {
    func hookUI() {
        self.favouritesUI?.setNumberOfRowsHandler( { [weak self] in
            return self?.stockCellPresenter.getNumberOfRows() ?? 0
        })
        self.favouritesUI?.setHeightForRowHandler( { [weak self] indexPath in
            return self?.stockCellPresenter.getHeightForRow(at: indexPath) ?? 0
        })
        self.favouritesUI?.setCellWillAppearHandler( { [weak self] cell, indexPath in
            self?.stockCellPresenter.cellWillAppear(cell, at: indexPath, favouriteButtonHandler: {
                self?.handleStocksLoading()
            })
        })
        self.favouritesUI?.setTitleForHeaderHandler( { [weak self] in
            return self?.stockCellPresenter.titleForHeader() ?? ""
        })
        self.favouritesUI?.setDidSelectRowHandler( { [weak self] indexPath in
            self?.stockCellPresenter.didSelectRow(at: indexPath) { previewStock in
                print(previewStock?.ticker)
            }
        })
        self.favouritesUI?.setRefreshDataHandler({ [weak self] in
            self?.stockCellPresenter.refreshStocks { error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.favouritesUI?.stopRefreshingAnimation()
                    if let error = error as? NetworkError, error == NetworkError.limitExceeded {
                        let errorMessage = "Лимит запросов превышен. Пожалуйста, повторите ваше действие через минуту"
                        self.navigator.errorOccured(with: errorMessage)
                        return
                    }
                    self.favouritesUI?.reloadData()
                }
            }
        })
    }
    
    func handleStocksLoading() {
        self.stockCellPresenter.loadStocks { [weak self] _ in
            self?.favouritesUI?.reloadDataWithoutAnimation()
        }
    }
}
