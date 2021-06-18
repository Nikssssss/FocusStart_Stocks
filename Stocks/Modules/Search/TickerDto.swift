//
//  TickerDto.swift
//  Stocks
//
//  Created by Никита Гусев on 12.06.2021.
//

import Foundation

struct LookupDto: Decodable {
    let result: [TickerDto]
}

struct TickerDto: Decodable {
    let symbol: String
}
