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
        self.handleStocksLoading(using: nil)
    }
    
    func searchBarShouldBeginEditing(with searchText: String?) {
        guard let searchText = searchText,
              searchText.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            return
        }
        self.stockCellPresenter.changeState(to: .recentStocks)
        self.handleStocksLoading(using: nil)
    }
    
    func searchBarSearchButtonClicked(with searchText: String?) {
        guard let searchText = searchText,
              searchText.trimmingCharacters(in: .whitespaces).isEmpty == false
        else {
            self.stockCellPresenter.changeState(to: .recentStocks)
            self.handleStocksLoading(using: nil)
            return
        }
        self.stockCellPresenter.changeState(to: .searchedStocks)
        self.handleStocksLoading(using: searchText)
    }
    
    func searchBarCancelButtonClicked() {
        self.stockCellPresenter.changeState(to: .defaultStocks)
        self.handleStocksLoading(using: nil)
    }
    
    func searchBarTextDidChange(to searchText: String) {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            self.stockCellPresenter.changeState(to: .recentStocks)
            self.handleStocksLoading(using: nil)
        }
    }
}

private extension SearchPresenter {
    func hookUI() {
        self.searchUI?.numberOfRowsHandler = { [weak self] in
            return self?.stockCellPresenter.getNumberOfRows() ?? 0
        }
        self.searchUI?.heightForRowAt = { [weak self] indexPath in
            return self?.stockCellPresenter.getHeightForRow(at: indexPath) ?? 0
        }
        self.searchUI?.cellWillAppear = { [weak self] cell, indexPath in
            self?.stockCellPresenter.cellWillAppear(cell, at: indexPath, favouriteButtonHandler: {
                DispatchQueue.main.async {
                    self?.searchUI?.reloadDataWithoutAnimation()
                }
            })
        }
        self.searchUI?.titleForHeader = { [weak self] in
            return self?.stockCellPresenter.titleForHeader() ?? ""
        }
        self.searchUI?.didSelectRowAt = { [weak self] indexPath in
            self?.stockCellPresenter.didSelectRow(at: indexPath) { previewStock in
                print(previewStock?.ticker)
            }
        }
    }
    
    func handleStocksLoading(using searchText: String?) {
        let completion = self.createStocksLoadingCompletionHandler()
        if let searchText = searchText {
            let loadingMessage = "Идет загрузка данных..."
            self.searchUI?.showLoadingAnimation(with: loadingMessage)
            self.stockCellPresenter.loadStocks(using: searchText, completion: completion)
        } else {
            self.stockCellPresenter.loadStocks(completion: completion)
        }
    }
    
    func createStocksLoadingCompletionHandler() -> ((Error?) -> Void) {
        let completion: (Error?) -> Void = { [weak self] error in
            guard let self = self else { return }
            if let error = error as? NetworkError, error == NetworkError.limitExceeded {
                DispatchQueue.main.async {
                    self.viewShouldStopLoading()
                    let errorMessage = "Лимит запросов превышен. Пожалуйста, повторите ваше действие через минуту"
                    self.navigator.errorOccured(with: errorMessage)
                }
                return
            }
            DispatchQueue.main.async {
                self.viewShouldStopLoading()
            }
        }
        return completion
    }
    
    func viewShouldStopLoading() {
        self.searchUI?.hideLoadingAnimation()
        self.searchUI?.reloadData()
    }
}
