//
//  AuthView.swift
//  Stocks
//
//  Created by Никита Гусев on 11.06.2021.
//

import UIKit

class AuthView: UIView {
    var signInButtonTapHandler: ((UserAuthViewModel) -> Void)?
    var signUpButtonTapHandler: (() -> Void)?
    
    private let credentialsStackView = UIStackView()
    private let loginTextField = UITextField()
    private let passwordTextField = UITextField()
    private let signInButton = UIButton()
    private let signUpButton = UIButton()
    
    func configureView() {
        self.backgroundColor = .white
        self.addSubviews()
        self.configureCredentialsStackView()
        self.configureTextFields()
        self.configureButtons()
    }
}

private extension AuthView {
    func addSubviews() {
        self.addSubview(self.credentialsStackView)
        self.addSubview(self.signInButton)
        self.addSubview(self.signUpButton)
    }
    
    func configureCredentialsStackView() {
        self.credentialsStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        self.credentialsStackView.distribution = .fillEqually
        self.credentialsStackView.axis = .vertical
        self.credentialsStackView.spacing = 20
    }
    
    func configureTextFields() {
        self.configureTextField(self.loginTextField,
                                placeholder: "Логин", iconName: "person.fill")
        self.configureTextField(self.passwordTextField,
                                placeholder: "Пароль", iconName: "lock.fill")
    }
    
    func configureTextField(_ textField: UITextField, placeholder: String, iconName: String) {
        textField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        textField.placeholder = placeholder
        textField.backgroundColor = UIColor(red: 240.0 / 255,
                                            green: 240.0 / 255,
                                            blue: 240.0 / 255,
                                            alpha: 1.0)
        textField.layer.cornerRadius = 10
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        self.configureTextFieldIconView(textField, iconName: iconName)
        self.credentialsStackView.addArrangedSubview(textField)
    }
    
    func configureTextFieldIconView(_ textField: UITextField, iconName: String) {
        let iconImageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 23, height: 20))
        let iconImage = UIImage(systemName: iconName)
        iconImageView.image = iconImage?.withRenderingMode(.alwaysOriginal).withTintColor(.lightGray)
        let iconContainerView = UIView(frame: CGRect(x: 20, y: 0, width: 33, height: 30))
        iconContainerView.addSubview(iconImageView)
        textField.leftView = iconContainerView
        textField.leftViewMode = .always
    }
    
    func configureButtons() {
        self.configureSignInButton()
        self.configureSignUpButton()
    }
    
    func configureSignInButton() {
        self.signInButton.snp.makeConstraints { make in
            make.top.equalTo(self.credentialsStackView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(200)
        }
        self.signInButton.setTitle("Войти", for: .normal)
        self.signInButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        self.signInButton.setTitleColor(.white, for: .normal)
        self.signInButton.layer.cornerRadius = 10
        self.signInButton.backgroundColor = .black
        self.signInButton.addTarget(self,
                                    action: #selector(self.signInButtonPressed),
                                    for: .touchUpInside)
    }
    
    func configureSignUpButton() {
        self.signUpButton.snp.makeConstraints { make in
            make.top.equalTo(self.signInButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        self.signUpButton.setTitle("Зарегистрироваться", for: .normal)
        self.signUpButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        self.signUpButton.setTitleColor(.darkGray, for: .normal)
        self.signUpButton.addTarget(self,
                                    action: #selector(self.signUpButtonPressed),
                                    for: .touchUpInside)
    }
    
    @objc func signInButtonPressed() {
        let login = self.loginTextField.text
        let password = self.passwordTextField.text
        let userViewModel = UserAuthViewModel(login: login, password: password)
        self.signInButtonTapHandler?(userViewModel)
    }
    
    @objc func signUpButtonPressed() {
        self.signUpButtonTapHandler?()
    }
}
