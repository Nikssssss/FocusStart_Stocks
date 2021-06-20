//
//  AuthUI.swift
//  Stocks
//
//  Created by Никита Гусев on 11.06.2021.
//

import UIKit

protocol IAuthUI: class {
    var signInButtonTapHandler: ((UserAuthViewModel) -> Void)? { get set }
    var signUpButtonTapHandler: (() -> Void)? { get set }
    
    func replaceScreenView()
    func configureUI()
}

class AuthUI: UIViewController {
    private let authView = AuthView()
    private var presenter: IAuthPresenter?
    
    func setPresenter(_ presenter: IAuthPresenter) {
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

extension AuthUI: IAuthUI {
    var signInButtonTapHandler: ((UserAuthViewModel) -> Void)? {
        get {
            return self.authView.signInButtonTapHandler
        }
        set {
            self.authView.signInButtonTapHandler = newValue
        }
    }
    
    var signUpButtonTapHandler: (() -> Void)? {
        get {
            return self.authView.signUpButtonTapHandler
        }
        set {
            self.authView.signUpButtonTapHandler = newValue
        }
    }
    
    func replaceScreenView() {
        self.view = self.authView
    }
    
    func configureUI() {
        self.configureNavigationBar()
        self.authView.configureView()
    }
}

private extension AuthUI {
    func configureNavigationBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.backgroundColor = .white
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationAppearance
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationItem.title = AuthConstants.navigationBarTitle
    }
}
