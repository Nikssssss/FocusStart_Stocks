//
//  AuthAssembly.swift
//  Stocks
//
//  Created by Никита Гусев on 11.06.2021.
//

import Foundation

final class AuthAssembly {
    static func makeModule() -> ModuleNavigationItem? {
        let container = DependencyContainer.shared.container
        guard let storageManager = container.resolve(IStorageManager.self),
              let navigator = container.resolve(INavigator.self),
              let authSecurityService = container.resolve(IAuthSecurityService.self)
        else { return nil }
        
        let authUI = AuthUI()
        
        let presenter = AuthPresenter(authUI: authUI,
                                      storageManager: storageManager,
                                      navigator: navigator,
                                      authSecurityService: authSecurityService)
        
        authUI.setPresenter(presenter)
        
        let moduleNavigationItem = ModuleNavigationItem(viewController: authUI)
        return moduleNavigationItem
    }
}
