//
//  RegisterUI.swift
//  Stocks
//
//  Created by Никита Гусев on 11.06.2021.
//

import UIKit

protocol IRegisterUI: class {
    var signUpButtonTapHandler: ((UserRegisterViewModel) -> Void)? { get set }
    
    func replaceScreenView()
    func configureUI()
}

class RegisterUI: UIViewController {
    private let registerView = RegisterView()
    private var presenter: IRegisterPresenter?
    
    func setPresenter(_ presenter: IRegisterPresenter) {
        self.presenter = presenter
    }
    
    override func loadView() {
        super.loadView()
        
        self.presenter?.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter?.viewDidLoad()
    }
}

extension RegisterUI: IRegisterUI {
    var signUpButtonTapHandler: ((UserRegisterViewModel) -> Void)? {
        get {
            return self.registerView.signUpButtonTapHandler
        }
        set {
            self.registerView.signUpButtonTapHandler = newValue
        }
    }
    
    func replaceScreenView() {
        self.view = self.registerView
    }
    
    func configureUI() {
        self.configureNavigationBar()
        self.registerView.configureView()
    }
}

private extension RegisterUI {
    func configureNavigationBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.backgroundColor = .white
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationAppearance
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationItem.title = "Создать аккаунт"
        self.navigationController?.navigationBar.tintColor = .black
        let backBarButton = UIBarButtonItem()
        backBarButton.title = "Авторизация"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backBarButton
    }
}
