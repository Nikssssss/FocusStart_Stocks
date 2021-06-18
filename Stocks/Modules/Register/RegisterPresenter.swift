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
            let message = "Пожалуйста, заполните все поля или проверьте совпадение введенных паролей"
            self.navigator.errorOccured(with: message)
            return
        }
        let isAdded = self.storageManager.addUser(user: userStorageDto)
        if isAdded, let password = userViewModel.password {
            self.authSecurityService.savePassword(password, for: userStorageDto.login)
            self.addDefaultStocks(to: userStorageDto)
            self.navigator.signUpButtonPressedAtRegister()
        } else {
            let message = "Пользователь с таким логином уже существует"
            self.navigator.errorOccured(with: message)
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
        self.networkManager.loadAllStocks(with: defaultStocksTickers) { downloadedStocksResult in
            switch downloadedStocksResult {
            case .failure(let error):
                if error == NetworkError.limitExceeded {
                    let errorMessage = "Лимит запросов превышен. Пожалуйста, повторите ваше действие через минуту"
                    self.navigator.errorOccured(with: errorMessage)
                }
            case .success(let downloadedStocks):
                self.saveAllDownloadedDefaultStocks(downloadedStocks: downloadedStocks, to: user)
            }
        }
    }
    
    func saveAllDownloadedDefaultStocks(downloadedStocks: [DownloadedStockDto], to user: UserStorageDto) {
        for downloadedStock in downloadedStocks {
            let quote = downloadedStock.quote
            let delta = DeltaCounter.countDelta(openPrice: quote.openPrice,
                                                currentPrice: quote.currentPrice)
            let previewStock = StockMapper.downloadedToPreview(downloadedStock,
                                                               delta: delta,
                                                               isFavourite: false)
            self.storageManager.addDefaultStock(stockDto: previewStock, to: user)
        }
    }
}
