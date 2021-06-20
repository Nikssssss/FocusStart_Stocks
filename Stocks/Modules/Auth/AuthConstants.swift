//
//  AuthConstants.swift
//  Stocks
//
//  Created by Никита Гусев on 20.06.2021.
//

import Foundation
import UIKit

struct AuthConstants {
    //MARK: AuthUI
    
    static let navigationBarTitle = "Добро пожаловать!"
    
    //MARK: AuthView
    
    static let viewBackgroundColor = UIColor.white
    static let textFieldsSpacing: CGFloat = 20
    static let loginPlaceholder = "Логин"
    static let loginIconName = "person.fill"
    static let passwordPlaceholder = "Пароль"
    static let passwordIconName = "lock.fill"
    
    static let textFieldBackgroundColor = UIColor(red: 240.0 / 255,
                                                  green: 240.0 / 255,
                                                  blue: 240.0 / 255,
                                                  alpha: 1.0)
    static let textFieldCornerRadius: CGFloat = 10
    
    static let iconImageFrame = CGRect(x: 5, y: 5, width: 23, height: 20)
    static let iconImageContainerFrame = CGRect(x: 20, y: 0, width: 33, height: 30)
    
    static let signInButtonTitle = "Войти"
    static let signInButtonFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
    static let signInButtonTextColor = UIColor.white
    static let signInButtonCornerRadius: CGFloat = 10
    static let signInButtonBackgroundColor = UIColor.black
    
    static let signUpButtonTitle = "Зарегистрироваться"
    static let signUpButtonFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
    static let signUpButtonTextColor = UIColor.darkGray
}
