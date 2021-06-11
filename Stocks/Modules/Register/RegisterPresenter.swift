//
//  RegisterPresenter.swift
//  Stocks
//
//  Created by Никита Гусев on 11.06.2021.
//

import Foundation

protocol IRegisterPresenter: class {
    func loadView()
    func viewDidLoad()
}

final class RegisterPresenter: IRegisterPresenter {
    private weak var registerUI: IRegisterUI?
    private let storageManager: IStorageManager
    private let networkManager: INetworkManager
    private let navigator: INavigator
    
    init(registerUI: IRegisterUI,
         storageManager: IStorageManager,
         networkManager: INetworkManager,
         navigator: INavigator) {
        self.registerUI = registerUI
        self.storageManager = storageManager
        self.networkManager = networkManager
        self.navigator = navigator
    }
    
    func loadView() {
        self.registerUI?.replaceScreenView()
    }
    
    func viewDidLoad() {
        self.hookUI()
        self.registerUI?.configureUI()
    }
}

private extension RegisterPresenter {
    func hookUI() {
        self.registerUI?.signUpButtonTapHandler = { [weak self] userViewModel in
            self?.signUpUser(using: userViewModel)
        }
    }
    
    func signUpUser(using userViewModel: UserRegisterViewModel) {
        guard self.validateEntry(of: userViewModel) == true else {
            //TODO: show error on view
            print("validation error")
            return
        }
        //TODO: encrypt password
        //TODO: register user and add default stocks
    }
    
    func validateEntry(of userViewModel: UserRegisterViewModel) -> Bool {
        guard let login = userViewModel.login,
              let password = userViewModel.password,
              let confirmPassword = userViewModel.confirmPassword,
              login.isEmpty == false,
              password.isEmpty == false,
              confirmPassword.isEmpty == false,
              password == confirmPassword
        else { return false }
        return true
    }
}
