//
//  FavouritesView.swift
//  Stocks
//
//  Created by Никита Гусев on 15.06.2021.
//

import Foundation
import UIKit

class FavouritesView: UIView {
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
        self.stocksTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
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
}

private extension FavouritesView {
    func addSubviews() {
        self.addSubview(self.stocksTableView)
    }
    
    func configureStocksTableView() {
        self.stocksTableView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(10)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.stocksTableView.configureView()
    }
}
