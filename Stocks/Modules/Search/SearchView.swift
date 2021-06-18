//
//  SearchView.swift
//  Stocks
//
//  Created by Никита Гусев on 08.06.2021.
//

import UIKit
import SnapKit

class SearchView: UIView {
    private let stocksTableView = PreviewStocksTableView()
    
    func congigureView() {
        self.backgroundColor = .white
        self.addSubviews()
        self.configureStocksTableView()
    }
    
    func reloadData() {
        self.stocksTableView.reloadSections(IndexSet(integer: 0), with: .middle)
    }
    
    func reloadDataWithoutAnimation() {
        self.stocksTableView.reloadSections(IndexSet(integer: 0), with: .none)
    }
    
    func setNumberOfRowsHandler(_ numberOfRowsHandler: (() -> Int)?) {
        self.stocksTableView.numberOfRowsHandler = numberOfRowsHandler
    }
    
    func setCellWillAppearHandler(_ cellWillAppear: ((IStockTableCell, IndexPath) -> Void)?) {
        self.stocksTableView.cellWillAppear = cellWillAppear
    }
    
    func setHeightForRowHandler(_ heightForRowAt: ((_ indexPath: IndexPath) -> CGFloat)?) {
        self.stocksTableView.heightForRowAt = heightForRowAt
    }
    
    func setTitleForHeaderHandler(_ titleForHeader: (() -> String)?) {
        self.stocksTableView.titleForHeader = titleForHeader
    }
    
    func setDidSelectRowHandler(_ didSelectRowAt: ((_ indexPath: IndexPath) -> Void)?) {
        self.stocksTableView.didSelectRowAt = didSelectRowAt
    }
    
    func setRefreshDataHandler(_ refreshDataHandler: (() -> Void)?) {
        self.stocksTableView.refreshDataHandler = refreshDataHandler
    }
    
    func stopRefreshingAnimation() {
        self.stocksTableView.refreshControl?.endRefreshing()
    }
}

private extension SearchView {
    func addSubviews() {
        self.addSubview(self.stocksTableView)
    }
    
    func configureStocksTableView() {
        self.stocksTableView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.stocksTableView.configureView()
    }
}
