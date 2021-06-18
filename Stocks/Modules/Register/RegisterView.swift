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
        self.backgroundColor = .white
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
        self.credentialsStackView.spacing = 20
    }
    
    func configureTextFields() {
        self.configureTextField(self.loginTextField,
                                placeholder: "Логин", iconName: "person.fill")
        self.configureTextField(self.passwordTextField,
                                placeholder: "Пароль", iconName: "lock.fill")
        self.configureTextField(self.confirmPasswordTextField,
                                placeholder: "Подтвердите пароль", iconName: "lock.fill")
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
    
    func configureSignUpButton() {
        self.signUpButton.snp.makeConstraints { make in
            make.top.equalTo(self.credentialsStackView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(200)
        }
        self.signUpButton.setTitle("Зарегистрироваться", for: .normal)
        self.signUpButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        self.signUpButton.setTitleColor(.white, for: .normal)
        self.signUpButton.layer.cornerRadius = 10
        self.signUpButton.backgroundColor = .black
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
