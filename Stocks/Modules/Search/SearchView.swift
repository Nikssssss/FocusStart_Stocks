//
//  SearchView.swift
//  Stocks
//
//  Created by Никита Гусев on 08.06.2021.
//

import UIKit
import SnapKit

class SearchView: UIView {
    var numberOfRowsHandler: (() -> Int)?
    var cellWillAppear: ((IStockTableCell, IndexPath) -> Void)?
    var heightForRowAt: ((_ indexPath: IndexPath) -> CGFloat)?
    
    private let stocksSearchBar = UISearchBar()
    private let stocksTableView = UITableView()
    
    func congigureView() {
        self.backgroundColor = .white
        self.addSubviews()
        self.configureStocksSearchBar()
        self.configureStocksTableView()
    }
    
    func reloadData() {
        self.stocksTableView.reloadData()
    }
}

extension SearchView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRowsHandler?() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StockTableViewCell.identifier,
                                                       for: indexPath) as? StockTableViewCell
        else { return UITableViewCell() }
        self.cellWillAppear?(cell, indexPath)
        return cell
    }
}

extension SearchView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightForRowAt?(indexPath) ?? 0
    }
}

extension SearchView: UISearchBarDelegate {
    
}

private extension SearchView {
    func addSubviews() {
        self.addSubview(self.stocksSearchBar)
        self.addSubview(self.stocksTableView)
    }
    
    func configureStocksSearchBar() {
        self.stocksSearchBar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
        }
        self.stocksSearchBar.autocapitalizationType = .none
        self.stocksSearchBar.autocorrectionType = .no
        self.stocksSearchBar.backgroundImage = UIImage()
        self.stocksSearchBar.placeholder = "Введите тикер или название компании"
        self.stocksSearchBar.delegate = self
    }
    
    func configureStocksTableView() {
        self.stocksTableView.snp.makeConstraints { make in
            make.top.equalTo(self.stocksSearchBar.snp.bottom)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.stocksTableView.register(StockTableViewCell.self,
                                      forCellReuseIdentifier: StockTableViewCell.identifier)
        self.stocksTableView.dataSource = self
        self.stocksTableView.delegate = self
        self.stocksTableView.tableFooterView = UIView()
        self.stocksTableView.separatorStyle = .none
    }
}
