//
//  RegisterAssembly.swift
//  Stocks
//
//  Created by Никита Гусев on 11.06.2021.
//

import Foundation
import class UIKit.UIApplication

final class RegisterAssembly {
    static func makeModule() -> ModuleNavigationItem? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let container = appDelegate?.container,
              let storageManager = container.resolve(IStorageManager.self),
              let networkManager = container.resolve(INetworkManager.self),
              let navigator = container.resolve(INavigator.self),
              let authSecurityService = container.resolve(IAuthSecurityService.self),
              let configurationReader = container.resolve(IConfigurationReader.self)
        else { return nil }
        
        let registerUI = RegisterUI()
        
        let presenter = RegisterPresenter(registerUI: registerUI,
                                          storageManager: storageManager,
                                          networkManager: networkManager,
                                          navigator: navigator,
                                          authSecurityService: authSecurityService,
                                          configurationReader: configurationReader)
        
        registerUI.setPresenter(presenter)
        
        let moduleNavigationItem = ModuleNavigationItem(viewController: registerUI, navigationItemTag: .main)
        return moduleNavigationItem
    }
}
