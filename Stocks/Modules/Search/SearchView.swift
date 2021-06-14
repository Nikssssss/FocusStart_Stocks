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
    var titleForHeader: (() -> String)?
    var didSelectRowAt: ((_ indexPath: IndexPath) -> Void)?
    
    private let stocksTableView = UITableView(frame: .zero, style: .grouped)
    
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.titleForHeader?()
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.tintColor = .white
        headerView.backgroundConfiguration?.backgroundColor = .white
        headerView.textLabel?.font = .systemFont(ofSize: 13, weight: .bold)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelectRowAt?(indexPath)
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
        self.stocksTableView.register(StockTableViewCell.self,
                                      forCellReuseIdentifier: StockTableViewCell.identifier)
        self.stocksTableView.dataSource = self
        self.stocksTableView.delegate = self
        self.stocksTableView.tableFooterView = UIView()
        self.stocksTableView.separatorStyle = .none
        self.stocksTableView.backgroundColor = .white
    }
}
