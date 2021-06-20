//
//  QuoteDto.swift
//  Stocks
//
//  Created by Никита Гусев on 20.06.2021.
//

import Foundation

struct QuoteDto: Decodable {
    let currentPrice: Double
    let openPrice: Double
    
    enum CodingKeys: String, CodingKey {
        case c
        case o
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        currentPrice = try values.decode(Double.self, forKey: .c)
        openPrice = try values.decode(Double.self, forKey: .o)
    }
}
