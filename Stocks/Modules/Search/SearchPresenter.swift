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
        self.hookUI()
        self.searchUI?.configureUI()
        self.stockCellPresenter.loadStocks {
            self.searchUI?.reloadData()
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
            self?.stockCellPresenter.cellWillAppear(cell, at: indexPath)
        }
    }
}
