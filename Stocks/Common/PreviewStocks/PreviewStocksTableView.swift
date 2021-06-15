//
//  PreviewStocksTableView.swift
//  Stocks
//
//  Created by Никита Гусев on 15.06.2021.
//

import UIKit

class PreviewStocksTableView: UITableView {
    var numberOfRowsHandler: (() -> Int)?
    var cellWillAppear: ((IStockTableCell, IndexPath) -> Void)?
    var heightForRowAt: ((_ indexPath: IndexPath) -> CGFloat)?
    var titleForHeader: (() -> String)?
    var didSelectRowAt: ((_ indexPath: IndexPath) -> Void)?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: .zero, style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        self.register(StockTableViewCell.self,
                      forCellReuseIdentifier: StockTableViewCell.identifier)
        self.delegate = self
        self.dataSource = self
        self.tableFooterView = UIView()
        self.separatorStyle = .none
        self.backgroundColor = .white
    }
}

extension PreviewStocksTableView: UITableViewDataSource {
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

extension PreviewStocksTableView: UITableViewDelegate {
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
