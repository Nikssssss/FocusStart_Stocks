//
//  AppDelegate.swift
//  Stocks
//
//  Created by Никита Гусев on 08.06.2021.
//

import UIKit
import Swinject

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let container = Container()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.registerDependencies()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

private extension AppDelegate {
    func registerDependencies() {
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

