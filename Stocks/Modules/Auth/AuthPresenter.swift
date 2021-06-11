//
//  AuthPresenter.swift
//  Stocks
//
//  Created by Никита Гусев on 11.06.2021.
//

import Foundation

protocol IAuthPresenter: class {
    func loadView()
    func viewDidLoad()
}

final class AuthPresenter: IAuthPresenter {
    private weak var authUI: IAuthUI?
    private let storageManager: IStorageManager
    private let navigator: INavigator
    
    init(authUI: IAuthUI, storageManager: IStorageManager, navigator: INavigator) {
        self.authUI = authUI
        self.storageManager = storageManager
        self.navigator = navigator
    }
    
    func loadView() {
        self.authUI?.replaceScreenView()
    }
    
    func viewDidLoad() {
        self.hookUI()
        self.authUI?.configureUI()
    }
}

private extension AuthPresenter {
    func hookUI() {
        self.authUI?.signInButtonTapHandler = { [weak self] userViewModel in
            self?.signInUser(using: userViewModel)
        }
        self.authUI?.signUpButtonTapHandler = { [weak self] in
            self?.navigator.registerButtonPressedAtAuth()
        }
    }
    
    func signInUser(using userViewModel: UserAuthViewModel) {
        guard self.validateEntry(of: userViewModel) == true else {
            //TODO: show error on view
            print("validation error")
            return
        }
        print("signInUser")
        //TODO: load user at storageManager
    }
    
    func validateEntry(of userViewModel: UserAuthViewModel) -> Bool {
        guard let login = userViewModel.login,
              let password = userViewModel.password,
              login.isEmpty == false,
              password.isEmpty == false
        else { return false }
        return true
    }
}
