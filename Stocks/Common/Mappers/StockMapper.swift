//
//  StockMapper.swift
//  Stocks
//
//  Created by Никита Гусев on 12.06.2021.
//

import Foundation

final class StockMapper {
    static func downloadedToPreview(_ downloadedStock: DownloadedStockDto,
                                    delta: Double,
                                    isFavourite: Bool) -> PreviewStockDto {
        let companyProfile = downloadedStock.companyProfile
        let quote = downloadedStock.quote
        let previewStockDto = PreviewStockDto(ticker: companyProfile.ticker,
                                              companyName: companyProfile.name,
                                              logoUrl: companyProfile.logo,
                                              price: quote.currentPrice,
                                              delta: delta,
                                              isFavourite: isFavourite)
        return previewStockDto
    }
    
    static func stockToPreview(_ stock: Stock) -> PreviewStockDto? {
        guard let ticker = stock.ticker,
              let companyName = stock.companyName,
              let logoUrl = stock.logoUrl
        else { return nil }
        let previewStockDto = PreviewStockDto(ticker: ticker,
                                              companyName: companyName,
                                              logoUrl: logoUrl,
                                              price: stock.price,
                                              delta: stock.delta,
                                              isFavourite: stock.isFavourite)
        return previewStockDto
    }
}
