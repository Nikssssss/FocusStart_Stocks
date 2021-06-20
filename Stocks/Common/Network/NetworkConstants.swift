//
//  ApiConstants.swift
//  Stocks
//
//  Created by Никита Гусев on 20.06.2021.
//

import Foundation

struct NetworkConstants {
    static let tickersUriWithSearchTextParam = "https://finnhub.io/api/v1/search?q=%@&\(token)"
    static let companyProfileUriWithTickerParam = "https://finnhub.io/api/v1/stock/profile2?symbol=%@&\(token)"
    static let quoteUriWithTickerParam = "https://finnhub.io/api/v1/quote?symbol=%@&\(token)"
    static let chartDataUrl = "https://finnhub.io/api/v1/stock/candle"
    static let dayChartTickerAndBeginTimeAndEndTimeParams = "?symbol=%@&resolution=60&from=%d&to=%d&\(token)"
    static let monthChartTickerAndBeginTimeAndEndTimeParams = "?symbol=%@&resolution=D&from=%d&to=%d&\(token)"
    static let yearChartTickerAndBeginTimeAndEndTimeParams = "?symbol=%@&resolution=W&from=%d&to=%d&\(token)"
    
    static let requestPerSecondLimit = 30
    static let limitExcessHttpCode = 429
    static let requestTimeout: Double = 5
    
    private static let token = "token=c0qeg5f48v6tskkorckg"
}
