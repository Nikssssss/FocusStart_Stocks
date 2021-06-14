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
    var numberOfRowsHandler: (() -> Int)? { get set }
    var cellWillAppear: ((IStockTableCell, IndexPath) -> Void)? { get set }
    var heightForRowAt: ((_ indexPath: IndexPath) -> CGFloat)? { get set }
    var titleForHeader: (() -> String)? { get set }
    var didSelectRowAt: ((_ indexPath: IndexPath) -> Void)? { get set }
    
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
}

extension SearchUI: ISearchUI {
    var numberOfRowsHandler: (() -> Int)? {
        get {
            return self.searchView.numberOfRowsHandler
        }
        set {
            self.searchView.numberOfRowsHandler = newValue
        }
    }
    
    var cellWillAppear: ((IStockTableCell, IndexPath) -> Void)? {
        get {
            return self.searchView.cellWillAppear
        }
        set {
            self.searchView.cellWillAppear = newValue
        }
    }
    
    var heightForRowAt: ((IndexPath) -> CGFloat)? {
        get {
            return self.searchView.heightForRowAt
        }
        set {
            self.searchView.heightForRowAt = newValue
        }
    }
    
    var titleForHeader: (() -> String)? {
        get {
            return self.searchView.titleForHeader
        }
        set {
            self.searchView.titleForHeader = newValue
        }
    }
    
    var didSelectRowAt: ((IndexPath) -> Void)? {
        get {
            return self.searchView.didSelectRowAt
        }
        set {
            self.searchView.didSelectRowAt = newValue
        }
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
