//
//  AlertController.swift
//  Stocks
//
//  Created by Никита Гусев on 14.06.2021.
//

import Foundation
import SwiftMessages

protocol IAlertController: class {
    func showErrorAlert(message: String)
}

final class AlertController: IAlertController {
    func showErrorAlert(message: String) {
        let config = self.createErrorConfig()
        let view = self.createErrorView(message: message)
        SwiftMessages.show(config: config, view: view)
    }
}

private extension AlertController {
    func createErrorConfig() -> SwiftMessages.Config {
        var config = SwiftMessages.Config()
        config.presentationStyle = .center
        config.presentationContext = .window(windowLevel: .alert)
        config.duration = .forever
        config.dimMode = .gray(interactive: true)
        return config
    }
    
    func createErrorView(message: String) -> MessageView {
        let title = "Ошибка"
        let buttonTitle = "Хорошо"
        let view = MessageView.viewFromNib(layout: .centeredView)
        view.configureTheme(backgroundColor: .white, foregroundColor: .darkGray)
        view.configureDropShadow()
        view.tapHandler = { _ in SwiftMessages.hide() }
        view.buttonTapHandler = { _ in SwiftMessages.hide() }
        view.button?.setTitle(buttonTitle, for: .normal)
        view.button?.setTitleColor(.link, for: .normal)
        view.button?.backgroundColor = .white
        view.configureBackgroundView(width: 250)
        view.configureContent(title: title, body: message)
        return view
    }
}
