//
//  SearchUI.swift
//  Stocks
//
//  Created by Никита Гусев on 08.06.2021.
//

import UIKit
import SwiftSpinner
import SwiftMessages

protocol ISearchUI: class {
    func setNumberOfRowsHandler(_ numberOfRowsHandler: (() -> Int)?)
    func setCellWillAppearHandler(_ cellWillAppear: ((IStockTableCell, IndexPath) -> Void)?)
    func setHeightForRowHandler(_ heightForRowAt: ((_ indexPath: IndexPath) -> CGFloat)?)
    func setTitleForHeaderHandler(_ titleForHeader: (() -> String)?)
    func setDidSelectRowHandler(_ didSelectRowAt: ((_ indexPath: IndexPath) -> Void)?)
    func replaceScreenView()
    func configureUI()
    func reloadData()
    func reloadDataWithoutAnimation()
    func showLoadingAnimation(with message: String)
    func hideLoadingAnimation()
}

class SearchUI: UIViewController {
    private let searchView = SearchView()
    private var presenter: ISearchPresenter?
    
    func setPresenter(_ presenter: ISearchPresenter) {
        self.presenter = presenter
    }
    
    override func loadView() {
        super.loadView()
        
        self.presenter?.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.presenter?.viewWillAppear()
    }
}

extension SearchUI: ISearchUI {
    func setNumberOfRowsHandler(_ numberOfRowsHandler: (() -> Int)?) {
        self.searchView.setNumberOfRowsHandler(numberOfRowsHandler)
    }
    
    func setCellWillAppearHandler(_ cellWillAppear: ((IStockTableCell, IndexPath) -> Void)?) {
        self.searchView.setCellWillAppearHandler(cellWillAppear)
    }
    
    func setHeightForRowHandler(_ heightForRowAt: ((IndexPath) -> CGFloat)?) {
        self.searchView.setHeightForRowHandler(heightForRowAt)
    }
    
    func setTitleForHeaderHandler(_ titleForHeader: (() -> String)?) {
        self.searchView.setTitleForHeaderHandler(titleForHeader)
    }
    
    func setDidSelectRowHandler(_ didSelectRowAt: ((IndexPath) -> Void)?) {
        self.searchView.setDidSelectRowHandler(didSelectRowAt)
    }
    
    func replaceScreenView() {
        self.view = self.searchView
    }
    
    func configureUI() {
        self.configureNavigationBar()
        self.searchView.congigureView()
    }
    
    func reloadData() {
        self.searchView.reloadData()
    }
    
    func reloadDataWithoutAnimation() {
        self.searchView.reloadDataWithoutAnimation()
    }
    
    func showLoadingAnimation(with message: String) {
        SwiftSpinner.show(message, animated: true)
    }
    
    func hideLoadingAnimation() {
        SwiftSpinner.hide()
    }
}

extension SearchUI: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.presenter?.searchBarCancelButtonClicked()
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.presenter?.searchBarShouldBeginEditing(with: searchBar.text)
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.presenter?.searchBarSearchButtonClicked(with: searchBar.text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.presenter?.searchBarTextDidChange(to: searchText)
    }
}

private extension SearchUI {
    func configureNavigationBar() {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.backgroundColor = .white
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationAppearance
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationItem.title = "Поиск"
        self.configureSearchController()
    }
    
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "Введите тикер или название компании"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.autocapitalizationType = .none
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
}
