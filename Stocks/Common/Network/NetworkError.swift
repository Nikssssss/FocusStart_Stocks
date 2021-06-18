//
//  NetworkError.swift
//  Stocks
//
//  Created by Никита Гусев on 13.06.2021.
//

import Foundation

enum NetworkError: Error {
    case limitExceeded, invalidUrl, noData
}
