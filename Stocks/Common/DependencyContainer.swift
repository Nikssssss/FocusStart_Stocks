//
//  DependencyContainer.swift
//  Stocks
//
//  Created by Никита Гусев on 19.06.2021.
//

import Foundation
import Swinject

final class DependencyContainer {
    static var shared: DependencyContainer = {
        let dependencyContainer = DependencyContainer()
        dependencyContainer.registerDependencies()
        return dependencyContainer
    }()
    
    let container = Container()
    
    private init() {
        self.registerDependencies()
    }
    
    private func registerDependencies() {
        self.container.register(IAlertController.self) { _ in
            return AlertController()
        }
        
        self.container.register(INavigator.self) { _ in
            let navigator = Navigator()
            if let alertController = self.container.resolve(IAlertController.self) {
                navigator.setAlertController(alertController)
            }
            return navigator
        }.inObjectScope(.container)
        
        self.container.register(IDataCacheManager.self) { _ in
            return DataFileManager()
        }
        
        self.container.register(INetworkManager.self) { _ in
            return NetworkManager()
        }
        
        self.container.register(IConfigurationReader.self) { _ in
            return ConfigurationReader()
        }
        
        self.container.register(IStorageManager.self) { _ in
            return StorageManager()
        }.inObjectScope(.container)
        
        self.container.register(IAuthSecurityService.self) { _ in
            return AuthSecurityService()
        }
    }
}
