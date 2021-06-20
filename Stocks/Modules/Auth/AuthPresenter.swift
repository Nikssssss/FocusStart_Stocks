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
    private let authSecurityService: IAuthSecurityService
    
    init(authUI: IAuthUI,
         storageManager: IStorageManager,
         navigator: INavigator,
         authSecurityService: IAuthSecurityService) {
        self.authUI = authUI
        self.storageManager = storageManager
        self.navigator = navigator
        self.authSecurityService = authSecurityService
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
            self?.navigator.signUpButtonPressedAtAuth()
        }
    }
    
    func signInUser(using userViewModel: UserAuthViewModel) {
        guard self.validateEntry(of: userViewModel) == true,
              let userStorageDto = UserMapper.authViewModelToStorageDto(userViewModel),
              let password = userViewModel.password else {
            self.navigator.errorOccured(with: AlertMessages.fillInAllFieldsMessage)
            return
        }
        let isUserLoaded = self.storageManager.loadUser(user: userStorageDto)
        let isCorrectPassword = self.authSecurityService.checkPassword(password,
                                                                       for: userStorageDto.login)
        if isUserLoaded && isCorrectPassword {
            self.navigator.signInButtonPressed()
        } else {
            self.navigator.errorOccured(with: AlertMessages.checkValidityMessage)
        }
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
