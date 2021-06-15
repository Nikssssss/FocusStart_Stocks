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

struct DownloadedStockDto {
    let companyProfile: CompanyProfileDto
    let quote: QuoteDto
}

struct PreviewStockDto {
    let ticker: String
    let companyName: String
    let logoUrl: String
    let price: Double
    let delta: Double
    let isFavourite: Bool
}

struct RefreshQuoteInfo {
    let ticker: String
    let quote: QuoteDto
}
