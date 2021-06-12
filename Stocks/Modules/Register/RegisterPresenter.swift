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
    private let authSecurityService: IAuthSecurityService
    private let configurationReader: IConfigurationReader
    
    init(registerUI: IRegisterUI,
         storageManager: IStorageManager,
         networkManager: INetworkManager,
         navigator: INavigator,
         authSecurityService: IAuthSecurityService,
         configurationReader: IConfigurationReader) {
        self.registerUI = registerUI
        self.storageManager = storageManager
        self.networkManager = networkManager
        self.navigator = navigator
        self.authSecurityService = authSecurityService
        self.configurationReader = configurationReader
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
        guard self.validateEntry(of: userViewModel) == true,
              let userStorageDto = UserMapper.registerViewModelToStorageDto(userViewModel) else {
            //TODO: show error on view
            print("signUpUser validateEntry == false")
            return
        }
        let isAdded = self.storageManager.addUser(user: userStorageDto)
        if isAdded, let password = userViewModel.password {
            self.authSecurityService.savePassword(password, for: userStorageDto.login)
            self.addDefaultStocks(to: userStorageDto)
            self.navigator.signUpButtonPressedAtRegister()
        } else {
            print("signUpUser isAdded == false")
            //TODO: show error on view
        }
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
    
    func addDefaultStocks(to user: UserStorageDto) {
        let defaultStocksTickers = self.configurationReader.getAllDefaultStocksTickers()
        self.networkManager.loadAllStocks(with: defaultStocksTickers) { downloadedStocks in
            downloadedStocks.forEach { downloadedStock in
                let quote = downloadedStock.quote
                let delta = DeltaCounter.countDelta(openPrice: quote.openPrice,
                                                    currentPrice: quote.currentPrice)
                let previewStock = StockMapper.downloadedToPreview(downloadedStock, delta: delta)
                self.storageManager.addDefaultStock(stockDto: previewStock, to: user)
            }
        }
    }
}
