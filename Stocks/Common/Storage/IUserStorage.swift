//
//  IUserStorage.swift
//  Stocks
//
//  Created by Никита Гусев on 20.06.2021.
//

import Foundation

protocol IUserStorage: class {
    func loadUser(user: UserStorageDto) -> Bool
    func addUser(user: UserStorageDto) -> Bool
}
