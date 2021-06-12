//
//  UserMapper.swift
//  Stocks
//
//  Created by Никита Гусев on 12.06.2021.
//

import Foundation

final class UserMapper {
    static func registerViewModelToStorageDto(_ registerViewModel: UserRegisterViewModel) -> UserStorageDto? {
        guard let login = registerViewModel.login else { return nil }
        return UserStorageDto(login: login)
    }
    
    static func authViewModelToStorageDto(_ authViewModel: UserAuthViewModel) -> UserStorageDto? {
        guard let login = authViewModel.login else { return nil }
        return UserStorageDto(login: login)
    }
}
