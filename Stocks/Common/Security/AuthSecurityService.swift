//
//  AuthSecurityService.swift
//  Stocks
//
//  Created by Никита Гусев on 11.06.2021.
//

import Foundation
import CryptoSwift

protocol IAuthSecurityService: class {
    func savePassword(_ password: String, for login: String)
    func checkPassword(_ password: String, for login: String) -> Bool
}

final class AuthSecurityService: IAuthSecurityService {
    private let serviceName = "StocksSecurityService"
    private let salt = "8192f6d6-cad4-11eb-b8bc-0242ac130003"
    
    func savePassword(_ password: String, for login: String) {
        let hashedPassword = self.hashPassword(password)
        let keychainItem = KeychainPasswordItem(service: serviceName, account: login)
        try? keychainItem.savePassword(hashedPassword)
    }
    
    func checkPassword(_ password: String, for login: String) -> Bool {
        do {
            let keychainItem = KeychainPasswordItem(service: serviceName, account: login)
            let actualPassword = try keychainItem.readPassword()
            let checkingPassword = self.hashPassword(password)
            return actualPassword == checkingPassword
        } catch {
            return false
        }
    }
    
    private func hashPassword(_ password: String) -> String {
        return (self.salt + password).sha256()
    }
}
