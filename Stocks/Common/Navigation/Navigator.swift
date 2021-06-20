//
//  Navigator.swift
//  Stocks
//
//  Created by Никита Гусев on 08.06.2021.
//

import Foundation
import UIKit

protocol INavigator: class {
    func launch() -> ModuleNavigationItem?
    func signInButtonPressed()
    func signUpButtonPressedAtAuth()
    func signUpButtonPressedAtRegister()
    func errorOccured(with message: String)
    func previewStockPressed(previewStock: PreviewStockDto)
}

final class Navigator: INavigator {
    private let moduleNavigator = ModuleNavigator()
    private var alertController: IAlertController?
    
    func setAlertController(_ alertController: IAlertController) {
        self.alertController = alertController
    }
    
    func launch() -> ModuleNavigationItem? {
        guard let authNavigationItem = AuthAssembly.makeModule() else { return nil }
        return self.moduleNavigator.launch(with: authNavigationItem)
    }
    
    func signInButtonPressed() {
        guard let searchNavigationItem = SearchAssembly.makeModule(),
              let favouritesNavigationItem = FavouritesAssembly.makeModule()
        else { return }
        self.moduleNavigator.configureSearchNavigation(using: searchNavigationItem)
        self.moduleNavigator.configureFavouritesNavigation(using: favouritesNavigationItem)
        self.moduleNavigator.presentTabs(representingBy: [searchNavigationItem,
                                                          favouritesNavigationItem])
    }
    
    func signUpButtonPressedAtAuth() {
        guard let registerNavigationItem = RegisterAssembly.makeModule() else { return }
        self.moduleNavigator.pushToMain(moduleNavigationItem: registerNavigationItem)
    }
    
    func signUpButtonPressedAtRegister() {
        self.moduleNavigator.popFromMain()
    }
    
    func errorOccured(with message: String) {
        self.alertController?.showErrorAlert(message: message)
    }
    
    func previewStockPressed(previewStock: PreviewStockDto) {
        guard let detailsNavigationItem = DetailsAssembly.makeModule(with: previewStock) else { return }
        self.moduleNavigator.pushToTabBar(moduleNavigationItem: detailsNavigationItem)
    }
}

private final class ModuleNavigator {
    private let mainNavigationController: UINavigationController
    private let tabBarController: UITabBarController
    private let searchNavigationController: UINavigationController
    private let favouritesNavigationController: UINavigationController
    
    init() {
        self.mainNavigationController = UINavigationController()
        self.tabBarController = UITabBarController()
        self.searchNavigationController = UINavigationController()
        self.favouritesNavigationController = UINavigationController()
    }
    
    func launch(with moduleNavigationItem: ModuleNavigationItem) -> ModuleNavigationItem {
        let startViewController = moduleNavigationItem.viewController
        self.mainNavigationController.setViewControllers([startViewController], animated: true)
        let navigationItem = ModuleNavigationItem(viewController: self.mainNavigationController)
        return navigationItem
    }
    
    func configureSearchNavigation(using moduleNavigationItem: ModuleNavigationItem) {
        let rootViewController = moduleNavigationItem.viewController
        self.configureTab(of: rootViewController,
                          tabTitle: TabBarConstants.searchTabTitle,
                          tabImageTitle: TabBarConstants.searchTabImageTitle)
        self.searchNavigationController.setViewControllers([rootViewController], animated: true)
    }
    
    func configureFavouritesNavigation(using moduleNavigationItem: ModuleNavigationItem) {
        let rootViewController = moduleNavigationItem.viewController
        self.configureTab(of: rootViewController,
                          tabTitle: TabBarConstants.favouritesTabTitle,
                          tabImageTitle: TabBarConstants.favouritesTabImageTitle)
        self.favouritesNavigationController.setViewControllers([rootViewController], animated: true)
    }
    
    func presentTabs(representingBy moduleNavigationItems: [ModuleNavigationItem]) {
        self.tabBarController.setViewControllers([self.searchNavigationController,
                                                  self.favouritesNavigationController], animated: true)
        self.tabBarController.modalPresentationStyle = .fullScreen
        self.tabBarController.modalTransitionStyle = .crossDissolve
        self.presentOnMain(moduleNavigationItem: ModuleNavigationItem(viewController: self.tabBarController))
    }
    
    func pushToMain(moduleNavigationItem: ModuleNavigationItem) {
        self.mainNavigationController.pushViewController(moduleNavigationItem.viewController, animated: true)
    }
    
    func pushToTabBar(moduleNavigationItem: ModuleNavigationItem) {
        let navigationController = self.tabBarController.selectedViewController as? UINavigationController
        navigationController?.pushViewController(moduleNavigationItem.viewController, animated: true)
    }
    
    func popFromMain() {
        self.mainNavigationController.popViewController(animated: true)
    }
    
    func presentOnMain(moduleNavigationItem: ModuleNavigationItem) {
        let viewController = moduleNavigationItem.viewController
        self.mainNavigationController.present(viewController, animated: true)
    }
    
    private func configureTab(of viewController: UIViewController,
                              tabTitle: String,
                              tabImageTitle: String) {
        viewController.tabBarItem.title = tabTitle
        viewController.tabBarItem.image = UIImage(systemName: tabImageTitle)
    }
}

