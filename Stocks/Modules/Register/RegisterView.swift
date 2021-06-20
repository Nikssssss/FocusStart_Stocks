//
//  RegisterView.swift
//  Stocks
//
//  Created by Никита Гусев on 11.06.2021.
//

import UIKit

class RegisterView: UIView {
    var signUpButtonTapHandler: ((UserRegisterViewModel) -> Void)?
    
    private let credentialsStackView = UIStackView()
    private let loginTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    private let signUpButton = UIButton()
    
    func configureView() {
        self.backgroundColor = RegisterConstants.viewBackgroundColor
        self.addSubviews()
        self.configureCredentialsStackView()
        self.configureTextFields()
        self.configureSignUpButton()
    }
}

private extension RegisterView {
    func addSubviews() {
        self.addSubview(self.credentialsStackView)
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
        self.credentialsStackView.spacing = RegisterConstants.textFieldsSpacing
    }
    
    func configureTextFields() {
        self.configureTextField(self.loginTextField,
                                placeholder: RegisterConstants.loginPlaceholder,
                                iconName: RegisterConstants.loginIconName)
        self.configureTextField(self.passwordTextField,
                                placeholder: RegisterConstants.passwordPlaceholder,
                                iconName: RegisterConstants.passwordIconName)
        self.configureTextField(self.confirmPasswordTextField,
                                placeholder: RegisterConstants.confirmPasswordPlaceholder,
                                iconName: RegisterConstants.passwordIconName)
    }
    
    func configureTextField(_ textField: UITextField, placeholder: String, iconName: String) {
        textField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        textField.placeholder = placeholder
        textField.backgroundColor = RegisterConstants.textFieldBackgroundColor
        textField.layer.cornerRadius = RegisterConstants.textFieldCornerRadius
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        self.configureTextFieldIconView(textField, iconName: iconName)
        self.credentialsStackView.addArrangedSubview(textField)
    }
    
    func configureTextFieldIconView(_ textField: UITextField, iconName: String) {
        let iconImageView = UIImageView(frame: RegisterConstants.iconImageFrame)
        let iconImage = UIImage(systemName: iconName)
        iconImageView.image = iconImage?.withRenderingMode(.alwaysOriginal).withTintColor(.lightGray)
        let iconContainerView = UIView(frame: RegisterConstants.iconImageContainerFrame)
        iconContainerView.addSubview(iconImageView)
        textField.leftView = iconContainerView
        textField.leftViewMode = .always
    }
    
    func configureSignUpButton() {
        self.signUpButton.snp.makeConstraints { make in
            make.top.equalTo(self.credentialsStackView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(200)
        }
        self.signUpButton.setTitle(RegisterConstants.signUpButtonTitle, for: .normal)
        self.signUpButton.titleLabel?.font = RegisterConstants.signUpButtonFont
        self.signUpButton.setTitleColor(RegisterConstants.signUpButtonTextColor, for: .normal)
        self.signUpButton.layer.cornerRadius = RegisterConstants.signUpButtonCornerRadius
        self.signUpButton.backgroundColor = RegisterConstants.signUpButtonBackgroundColor
        self.signUpButton.addTarget(self,
                                    action: #selector(self.signUpButtonPressed),
                                    for: .touchUpInside)
    }
    
    @objc func signUpButtonPressed() {
        let login = self.loginTextField.text
        let password = self.passwordTextField.text
        let confirmPassword = self.confirmPasswordTextField.text
        let userViewModel = UserRegisterViewModel(login: login,
                                                  password: password,
                                                  confirmPassword: confirmPassword)
        self.signUpButtonTapHandler?(userViewModel)
    }
}
