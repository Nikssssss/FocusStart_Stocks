//
//  ChartDto.swift
//  Stocks
//
//  Created by Никита Гусев on 20.06.2021.
//

import Foundation

struct ChartDto: Decodable {
    let prices: [Double]
    let datestamps: [Int64]
    
    enum CodingKeys: String, CodingKey {
        case c
        case t
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        prices = try values.decode([Double].self, forKey: .c)
        datestamps = try values.decode([Int64].self, forKey: .t)
    }
}
