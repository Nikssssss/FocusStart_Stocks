//
//  FavouritesUI.swift
//  Stocks
//
//  Created by Никита Гусев on 15.06.2021.
//

import UIKit

protocol IFavouritesUI: class {
    func setNumberOfRowsHandler(_ numberOfRowsHandler: (() -> Int)?)
    func setCellWillAppearHandler(_ cellWillAppear: ((IStockTableCell, IndexPath) -> Void)?)
    func setHeightForRowHandler(_ heightForRowAt: ((_ indexPath: IndexPath) -> CGFloat)?)
    func setTitleForHeaderHandler(_ titleForHeader: (() -> String)?)
    func setDidSelectRowHandler(_ didSelectRowAt: ((_ indexPath: IndexPath) -> Void)?)
    func replaceScreenView()
    func configureUI()
    func reloadData()
    func reloadDataWithoutAnimation()
}

class FavouritesUI: UIViewController {
    private let favouritesView = FavouritesView()
    private var presenter: IFavouritesPresenter?
    
    func setPresenter(_ presenter: IFavouritesPresenter) {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.presenter?.viewDidAppear()
    }
}

extension FavouritesUI: IFavouritesUI {
    func setNumberOfRowsHandler(_ numberOfRowsHandler: (() -> Int)?) {
        self.favouritesView.setNumberOfRowsHandler(numberOfRowsHandler)
    }
    
    func setCellWillAppearHandler(_ cellWillAppear: ((IStockTableCell, IndexPath) -> Void)?) {
        self.favouritesView.setCellWillAppearHandler(cellWillAppear)
    }
    
    func setHeightForRowHandler(_ heightForRowAt: ((IndexPath) -> CGFloat)?) {
        self.favouritesView.setHeightForRowHandler(heightForRowAt)
    }
    
    func setTitleForHeaderHandler(_ titleForHeader: (() -> String)?) {
        self.favouritesView.setTitleForHeaderHandler(titleForHeader)
    }
    
    func setDidSelectRowHandler(_ didSelectRowAt: ((IndexPath) -> Void)?) {
        self.favouritesView.setDidSelectRowHandler(didSelectRowAt)
    }
    
    func replaceScreenView() {
        self.view = self.favouritesView
    }
    
    func configureUI() {
        self.configureNavigationBar()
        self.favouritesView.congigureView()
    }
    
    func reloadData() {
        self.favouritesView.reloadData()
    }
    
    func reloadDataWithoutAnimation() {
        self.favouritesView.reloadDataWithoutAnimation()
    }
}

private extension FavouritesUI {
    func configureNavigationBar() {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.backgroundColor = .white
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationAppearance
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationItem.title = "Избранное"
    }
}
