//
//  NetworkManager.swift
//  Stocks
//
//  Created by Никита Гусев on 09.06.2021.
//

import Foundation
import Alamofire

protocol RestManager: class {
    func loadAllStocks(with tickers: [String], completion: @escaping (() -> Void))
}

protocol WebsocketManager: class {
    
}

protocol INetworkManager: WebsocketManager & RestManager {
    var downloadedStocks: [StockInfoDto] { get }
}

final class NetworkManager: INetworkManager {
    var downloadedStocks: [StockInfoDto] {
        return stockInfos.toArray
    }
    
    private var stockInfos = ThreadSafeArray<StockInfoDto>()
    
    func loadAllStocks(with tickers: [String], completion: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            let dispatchGroup = DispatchGroup()
            tickers.forEach { ticker in
                dispatchGroup.enter()
                self.loadStockInfo(for: ticker) {
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.wait()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

private extension NetworkManager {
    func loadStockInfo(for ticker: String, completion: @escaping (() -> Void)) {
        self.loadCompanyProfileInfo(for: ticker) { companyProfile in
            guard let companyProfile = companyProfile else { completion(); return }
            self.loadQuote(for: companyProfile) { quote in
                guard let quote = quote else { completion(); return }
                self.stockInfos.append(StockInfoDto(companyProfile: companyProfile, quote: quote))
                completion()
            }
        }
    }
    
    func loadCompanyProfileInfo(for ticker: String, completion: @escaping ((CompanyProfileDto?) -> Void)) {
        let urlString = "https://finnhub.io/api/v1/stock/profile2?token=c0qeg5f48v6tskkorckg"
        let companyProfileUrlString = urlString + "&symbol=\(ticker)"
        guard let companyProfileUrl = URL(string: companyProfileUrlString) else { completion(nil); return }
        
        AF.request(companyProfileUrl).responseJSON { jsonData in
            guard let data = jsonData.data else { completion(nil); return }
            let companyProfileDto = try? JSONDecoder().decode(CompanyProfileDto.self, from: data)
            completion(companyProfileDto)
        }
    }
    
    func loadQuote(for companyProfile: CompanyProfileDto, completion: @escaping ((QuoteDto?) -> Void)) {
        let urlString = "https://finnhub.io/api/v1/quote?token=c0qeg5f48v6tskkorckg"
        let quoteUrlString = urlString + "&symbol=\(companyProfile.ticker)"
        guard let quoteUrl = URL(string: quoteUrlString) else { completion(nil); return }
        
        AF.request(quoteUrl).responseJSON { jsonData in
            guard let data = jsonData.data else { completion(nil); return }
            let quoteDto = try? JSONDecoder().decode(QuoteDto.self, from: data)
            completion(quoteDto)
        }
    }
}
