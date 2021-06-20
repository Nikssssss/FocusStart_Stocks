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
        self.backgroundColor = AuthConstants.viewBackgroundColor
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
        self.credentialsStackView.spacing = AuthConstants.textFieldsSpacing
    }
    
    func configureTextFields() {
        self.configureTextField(self.loginTextField,
                                placeholder: AuthConstants.loginPlaceholder,
                                iconName: AuthConstants.loginIconName)
        self.configureTextField(self.passwordTextField,
                                placeholder: AuthConstants.passwordPlaceholder,
                                iconName: AuthConstants.passwordIconName)
    }
    
    func configureTextField(_ textField: UITextField, placeholder: String, iconName: String) {
        textField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        textField.placeholder = placeholder
        textField.backgroundColor = AuthConstants.textFieldBackgroundColor
        textField.layer.cornerRadius = AuthConstants.textFieldCornerRadius
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        self.configureTextFieldIconView(textField, iconName: iconName)
        self.credentialsStackView.addArrangedSubview(textField)
    }
    
    func configureTextFieldIconView(_ textField: UITextField, iconName: String) {
        let iconImageView = UIImageView(frame: AuthConstants.iconImageFrame)
        let iconImage = UIImage(systemName: iconName)
        iconImageView.image = iconImage?.withRenderingMode(.alwaysOriginal).withTintColor(.lightGray)
        let iconContainerView = UIView(frame: AuthConstants.iconImageContainerFrame)
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
        self.signInButton.setTitle(AuthConstants.signInButtonTitle, for: .normal)
        self.signInButton.titleLabel?.font = AuthConstants.signInButtonFont
        self.signInButton.setTitleColor(AuthConstants.signInButtonTextColor, for: .normal)
        self.signInButton.layer.cornerRadius = AuthConstants.signInButtonCornerRadius
        self.signInButton.backgroundColor = AuthConstants.signInButtonBackgroundColor
        self.signInButton.addTarget(self,
                                    action: #selector(self.signInButtonPressed),
                                    for: .touchUpInside)
    }
    
    func configureSignUpButton() {
        self.signUpButton.snp.makeConstraints { make in
            make.top.equalTo(self.signInButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        self.signUpButton.setTitle(AuthConstants.signUpButtonTitle, for: .normal)
        self.signUpButton.titleLabel?.font = AuthConstants.signUpButtonFont
        self.signUpButton.setTitleColor(AuthConstants.signUpButtonTextColor, for: .normal)
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
