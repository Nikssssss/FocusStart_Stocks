//
//  Navigator.swift
//  Stocks
//
//  Created by Никита Гусев on 08.06.2021.
//

import Foundation
import UIKit

enum NavigationItemTag {
    case main, search, favourites
}

protocol INavigator: class {
    func start()
    func getMainNavigationItem() -> ModuleNavigationItem
    func signInButtonPressed()
    func signUpButtonPressedAtAuth()
    func signUpButtonPressedAtRegister()
}

final class Navigator: INavigator {
    private let moduleNavigator = ModuleNavigator()
    
    func start() {
        guard let authNavigationItem = AuthAssembly.makeModule() else { return }
        self.moduleNavigator.start(with: authNavigationItem)
    }
    
    func getMainNavigationItem() -> ModuleNavigationItem {
        return self.moduleNavigator.getMainController()
    }
    
    func signInButtonPressed() {
        guard let searchNavigationItem = SearchAssembly.makeModule() else { return }
        self.moduleNavigator.presentTabBarController(with: [searchNavigationItem])
    }
    
    func signUpButtonPressedAtAuth() {
        guard let registerNavigationItem = RegisterAssembly.makeModule() else { return }
        self.moduleNavigator.push(moduleNavigationItem: registerNavigationItem)
    }
    
    func signUpButtonPressedAtRegister() {
        self.moduleNavigator.pop(navigationItemTag: .main)
    }
}

private final class ModuleNavigator {
    private let mainNavigationController: UINavigationController
    private let tabBarController: UITabBarController
    private let searchNavigationController: UINavigationController
    
    init() {
        self.mainNavigationController = UINavigationController()
        self.tabBarController = UITabBarController()
        self.searchNavigationController = UINavigationController()
    }
    
    func start(with moduleNavigationItem: ModuleNavigationItem) {
        let startViewController = moduleNavigationItem.viewController
        self.mainNavigationController.setViewControllers([startViewController], animated: true)
    }
    
    func getMainController() -> ModuleNavigationItem {
        let navigationItem = ModuleNavigationItem(viewController: self.mainNavigationController,
                                                  navigationItemTag: .main)
        return navigationItem
    }
    
    func presentTabBarController(with moduleNavigationItems: [ModuleNavigationItem]) {
        self.configureNavigationControllers(using: moduleNavigationItems)
        self.tabBarController.setViewControllers([self.searchNavigationController], animated: true)
        self.tabBarController.modalPresentationStyle = .fullScreen
        self.tabBarController.modalTransitionStyle = .crossDissolve
        self.mainNavigationController.present(self.tabBarController, animated: true)
    }
    
    func push(moduleNavigationItem: ModuleNavigationItem) {
        let navigationController = self.getNavigationController(with: moduleNavigationItem.navigationItemTag)
        navigationController.pushViewController(moduleNavigationItem.viewController, animated: true)
    }
    
    func pop(navigationItemTag: NavigationItemTag) {
        let navigationController = self.getNavigationController(with: navigationItemTag)
        navigationController.popViewController(animated: true)
    }
    
    func dismiss(navigationItemTag: NavigationItemTag) {
        let navigationController = self.getNavigationController(with: navigationItemTag)
        navigationController.dismiss(animated: true)
    }
    
    func present(moduleNavigationItem: ModuleNavigationItem) {
        let navigationController = self.getNavigationController(with: moduleNavigationItem.navigationItemTag)
        let viewController = moduleNavigationItem.viewController
        let presentedNavigationController = UINavigationController(rootViewController: viewController)
        navigationController.present(presentedNavigationController, animated: true)
    }
    
    private func configureNavigationControllers(using moduleNavigationItems: [ModuleNavigationItem]) {
        moduleNavigationItems.forEach { moduleNavigationItem in
            let viewController = moduleNavigationItem.viewController
            guard let tag = moduleNavigationItem.navigationItemTag else { return }
            switch tag {
            case .search:
                self.configureNavigationController(self.searchNavigationController,
                                                   rootViewController: viewController,
                                                   tabTitle: "Поиск",
                                                   tabImageTitle: "magnifyingglass.circle")
            default:
                break
            }
        }
    }
    
    private func configureNavigationController(_ navigationController: UINavigationController,
                                       rootViewController: UIViewController,
                                       tabTitle: String,
                                       tabImageTitle: String) {
        navigationController.setViewControllers([rootViewController], animated: true)
        rootViewController.tabBarItem.title = tabTitle
        rootViewController.tabBarItem.image = UIImage(systemName: tabImageTitle)
    }
    
    private func getNavigationController(with tag: NavigationItemTag?) -> UINavigationController {
        guard let tag = tag else {
            return UINavigationController()
        }
        switch tag {
        case .search:
            return self.searchNavigationController
        case .main:
            return self.mainNavigationController
        default:
            return UINavigationController()
        }
    }
}

