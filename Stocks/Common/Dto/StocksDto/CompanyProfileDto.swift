//
//  CompanyProfileDto.swift
//  Stocks
//
//  Created by Никита Гусев on 20.06.2021.
//

import Foundation

struct CompanyProfileDto: Decodable {
    let ticker: String
    let name: String
    let logo: String
}
