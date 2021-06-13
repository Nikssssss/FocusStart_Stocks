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
    func searchBarShouldBeginEditing()
    func searchBarTextDidChange(to searchText: String)
    func searchBarCancelButtonClicked()
}

final class SearchPresenter: ISearchPresenter {
    private weak var searchUI: ISearchUI?
    private let stockCellPresenter: IStockCellPresenter
    
    init(searchUI: ISearchUI, stockCellPresenter: IStockCellPresenter) {
        self.searchUI = searchUI
        self.stockCellPresenter = stockCellPresenter
    }
    
    func loadView() {
        self.searchUI?.replaceScreenView()
    }
    
    func viewDidLoad() {
        self.searchUI?.configureUI()
        self.hookUI()
        self.handleStocksLoading(using: nil)
    }
    
    func searchBarShouldBeginEditing() {
        self.stockCellPresenter.changeState(to: .recentStocks)
        self.handleStocksLoading(using: nil)
    }
    
    func searchBarTextDidChange(to searchText: String) {
        guard searchText.trimmingCharacters(in: .whitespaces).isEmpty == false else {
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
            self?.stockCellPresenter.cellWillAppear(cell, at: indexPath)
        }
        self.searchUI?.titleForHeader = { [weak self] in
            return self?.stockCellPresenter.titleForHeader() ?? ""
        }
    }
    
    func handleStocksLoading(using searchText: String?) {
        let completion: (Error?) -> Void = { [weak self] error in
            if let error = error as? NetworkError, error == NetworkError.limitExceeded {
                //TODO: show limit error on view
                print("limit exceeded")
            }
            DispatchQueue.main.async {
                self?.searchUI?.reloadData()
            }
        }
        if let searchText = searchText {
            self.stockCellPresenter.loadStocks(using: searchText, completion: completion)
        } else {
            self.stockCellPresenter.loadStocks(completion: completion)
        }
    }
}
