//
//  Navigator.swift
//  Stocks
//
//  Created by Никита Гусев on 08.06.2021.
//

import Foundation
import UIKit

protocol INavigator: class {
    func start()
    func getMainNavigationItem() -> ModuleNavigationItem
}

final class Navigator: INavigator {
    private let moduleNavigator = ModuleNavigator()
    
    func start() {
        let searchNavigationItem = SearchAssembly.makeModule()
        self.moduleNavigator.start(with: [searchNavigationItem])
    }
    
    func getMainNavigationItem() -> ModuleNavigationItem {
        return self.moduleNavigator.getMainController()
    }
}

private final class ModuleNavigator {
    private let tabBarController: UITabBarController
    private let searchNavigationController: UINavigationController
    
    init() {
        self.tabBarController = UITabBarController()
        self.searchNavigationController = UINavigationController()
    }
    
    func start(with moduleNavigationItems: [ModuleNavigationItem]) {
        self.configureNavigationControllers(using: moduleNavigationItems)
        self.tabBarController.setViewControllers([self.searchNavigationController], animated: true)
    }
    
    func getMainController() -> ModuleNavigationItem {
        let navigationItem = ModuleNavigationItem(viewController: self.tabBarController, tabItemTag: nil)
        return navigationItem
    }
    
    func push(moduleNavigationItem: ModuleNavigationItem) {
        let navigationController = self.getNavigationController(with: moduleNavigationItem.tabItemTag)
        navigationController.pushViewController(moduleNavigationItem.viewController, animated: true)
    }
    
    func dismiss(moduleNavigationItem: ModuleNavigationItem) {
        let navigationController = self.getNavigationController(with: moduleNavigationItem.tabItemTag)
        navigationController.dismiss(animated: true)
    }
    
    func present(moduleNavigationItem: ModuleNavigationItem) {
        let navigationController = self.getNavigationController(with: moduleNavigationItem.tabItemTag)
        let viewController = moduleNavigationItem.viewController
        let presentedNavigationController = UINavigationController(rootViewController: viewController)
        navigationController.present(presentedNavigationController, animated: true)
    }
    
    private func configureNavigationControllers(using moduleNavigationItems: [ModuleNavigationItem]) {
        moduleNavigationItems.forEach { moduleNavigationItem in
            let viewController = moduleNavigationItem.viewController
            guard let tag = moduleNavigationItem.tabItemTag else { return }
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
    
    private func getNavigationController(with tag: TabItemTag?) -> UINavigationController {
        guard let tag = tag else {
            return UINavigationController()
        }
        switch tag {
        case .search:
            return self.searchNavigationController
        default:
            return UINavigationController()
        }
    }
}

