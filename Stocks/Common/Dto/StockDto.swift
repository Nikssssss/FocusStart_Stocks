//
//  StockDto.swift
//  Stocks
//
//  Created by Никита Гусев on 09.06.2021.
//

import Foundation

struct CompanyProfileDto: Decodable {
    let ticker: String
    let name: String
    let logo: String
}

struct QuoteDto: Decodable {
    let currentPrice: Double
    
    enum CodingKeys: String, CodingKey {
        case c
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        currentPrice = try values.decode(Double.self, forKey: .c)
    }
}

struct StockInfoDto {
    let companyProfile: CompanyProfileDto
    let quote: QuoteDto
}
