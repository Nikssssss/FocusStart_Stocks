//
//  SceneDelegate.swift
//  Stocks
//
//  Created by Никита Гусев on 08.06.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let navigator = appDelegate.container.resolve(INavigator.self),
              let launchModuleNavigationItem = navigator.launch()
        else { return }
        window.rootViewController = launchModuleNavigationItem.viewController
        window.makeKeyAndVisible()
        self.window = window
    }
}

