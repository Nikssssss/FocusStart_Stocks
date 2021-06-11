//
//  SearchUI.swift
//  Stocks
//
//  Created by Никита Гусев on 08.06.2021.
//

import UIKit

protocol ISearchUI: class {
    var numberOfRowsHandler: (() -> Int)? { get set }
    var cellWillAppear: ((IStockTableCell, IndexPath) -> Void)? { get set }
    var heightForRowAt: ((_ indexPath: IndexPath) -> CGFloat)? { get set }
    var titleForHeader: (() -> String)? { get set }
    
    func replaceScreenView()
    func configureUI()
    func reloadData()
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
}

extension SearchUI: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarCancelButtonClicked")
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        print("searchBarShouldBeginEditing")
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
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
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
}
