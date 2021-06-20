//
//  SearchPresenter.swift
//  Stocks
//
//  Created by Никита Гусев on 08.06.2021.
//

import Foundation

protocol ISearchPresenter: class {
    func loadView()
    func viewDidLoad()
    func viewDidAppear()
    func searchBarShouldBeginEditing(with searchText: String?)
    func searchBarSearchButtonClicked(with searchText: String?)
    func searchBarCancelButtonClicked()
    func searchBarTextDidChange(to searchText: String)
}

final class SearchPresenter: ISearchPresenter {
    private weak var searchUI: ISearchUI?
    private let stockCellPresenter: IStockCellPresenter
    private let navigator: INavigator
    
    init(searchUI: ISearchUI, stockCellPresenter: IStockCellPresenter, navigator: INavigator) {
        self.searchUI = searchUI
        self.stockCellPresenter = stockCellPresenter
        self.navigator = navigator
    }
    
    func loadView() {
        self.searchUI?.replaceScreenView()
    }
    
    func viewDidLoad() {
        self.searchUI?.configureUI()
        self.hookUI()
    }
    
    func viewDidAppear() {
        self.handleStocksLoading(using: nil, animated: false)
    }
    
    func searchBarShouldBeginEditing(with searchText: String?) {
        guard let searchText = searchText,
              searchText.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            return
        }
        self.stockCellPresenter.changeState(to: .recentStocks)
        self.handleStocksLoading(using: nil, animated: true)
    }
    
    func searchBarSearchButtonClicked(with searchText: String?) {
        guard let searchText = searchText,
              searchText.trimmingCharacters(in: .whitespaces).isEmpty == false
        else {
            self.stockCellPresenter.changeState(to: .recentStocks)
            self.handleStocksLoading(using: nil, animated: true)
            return
        }
        self.stockCellPresenter.changeState(to: .searchedStocks)
        self.handleStocksLoading(using: searchText, animated: true)
    }
    
    func searchBarCancelButtonClicked() {
        self.stockCellPresenter.changeState(to: .defaultStocks)
        self.handleStocksLoading(using: nil, animated: true)
    }
    
    func searchBarTextDidChange(to searchText: String) {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            self.stockCellPresenter.changeState(to: .recentStocks)
            self.handleStocksLoading(using: nil, animated: true)
        }
    }
}

private extension SearchPresenter {
    func hookUI() {
        self.hookNumberOfRowsHandler()
        self.hookHeightForRowHandler()
        self.hookCellWillAppearHandler()
        self.hookTitleForHeaderHandler()
        self.hookDidSelectRowHandler()
        self.hookRefreshDataHandler()
    }
    
    func hookNumberOfRowsHandler() {
        self.searchUI?.setNumberOfRowsHandler( { [weak self] in
            return self?.stockCellPresenter.getNumberOfRows() ?? 0
        })
    }
    
    func hookHeightForRowHandler() {
        self.searchUI?.setHeightForRowHandler( { [weak self] indexPath in
            return self?.stockCellPresenter.getHeightForRow(at: indexPath) ?? 0
        })
    }
    
    func hookCellWillAppearHandler() {
        self.searchUI?.setCellWillAppearHandler( { [weak self] cell, indexPath in
            self?.stockCellPresenter.cellWillAppear(cell, at: indexPath, favouriteButtonHandler: {
                DispatchQueue.main.async {
                    self?.searchUI?.reloadDataWithoutAnimation()
                }
            })
        })
    }
    
    func hookTitleForHeaderHandler() {
        self.searchUI?.setTitleForHeaderHandler( { [weak self] in
            return self?.stockCellPresenter.titleForHeader() ?? ""
        })
    }
    
    func hookDidSelectRowHandler() {
        self.searchUI?.setDidSelectRowHandler( { [weak self] indexPath in
            guard let self = self else { return }
            self.stockCellPresenter.didSelectRow(at: indexPath) { previewStock in
                guard let previewStock = previewStock else { return }
                self.navigator.previewStockPressed(previewStock: previewStock)
                self.stockCellPresenter.stockPressed(stock: previewStock)
            }
        })
    }
    
    func hookRefreshDataHandler() {
        self.searchUI?.setRefreshDataHandler({ [weak self] in
            self?.stockCellPresenter.refreshStocks { error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.searchUI?.stopRefreshingAnimation()
                    if let error = error as? NetworkError, error == NetworkError.limitExceeded {
                        self.navigator.errorOccured(with: AlertMessages.limitExcessMessage)
                        return
                    }
                    self.searchUI?.reloadData()
                }
            }
        })
    }
    
    func handleStocksLoading(using searchText: String?, animated: Bool) {
        let completion = self.createStocksLoadingCompletionHandler(animated: animated)
        if let searchText = searchText {
            self.searchUI?.showLoadingAnimation(with: AlertMessages.loadingDataMessage)
            self.stockCellPresenter.loadStocks(using: searchText, completion: completion)
        } else {
            self.stockCellPresenter.loadStocks(completion: completion)
        }
    }
    
    func createStocksLoadingCompletionHandler(animated: Bool) -> ((Error?) -> Void) {
        let completion: (Error?) -> Void = { [weak self] error in
            guard let self = self else { return }
            if let error = error as? NetworkError, error == NetworkError.limitExceeded {
                DispatchQueue.main.async {
                    self.viewShouldStopLoading(animated: animated)
                    self.navigator.errorOccured(with: AlertMessages.limitExcessMessage)
                }
                return
            }
            DispatchQueue.main.async {
                self.viewShouldStopLoading(animated: animated)
            }
        }
        return completion
    }
    
    func viewShouldStopLoading(animated: Bool) {
        self.searchUI?.hideLoadingAnimation()
        if animated {
            self.searchUI?.reloadData()
        } else {
            self.searchUI?.reloadDataWithoutAnimation()
        }
    }
}
