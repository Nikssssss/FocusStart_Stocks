//
//  AuthAssembly.swift
//  Stocks
//
//  Created by Никита Гусев on 11.06.2021.
//

import Foundation
import class UIKit.UIApplication

final class AuthAssembly {
    static func makeModule() -> ModuleNavigationItem? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let container = appDelegate?.container,
              let storageManager = container.resolve(IStorageManager.self),
              let navigator = container.resolve(INavigator.self)
        else { return nil }
        
        let authUI = AuthUI()
        
        let presenter = AuthPresenter(authUI: authUI,
                                          storageManager: storageManager,
                                          navigator: navigator)
        
        authUI.setPresenter(presenter)
        
        let moduleNavigationItem = ModuleNavigationItem(viewController: authUI, navigationItemTag: .main)
        return moduleNavigationItem
    }
}
