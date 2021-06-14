//
//  NetworkManager.swift
//  Stocks
//
//  Created by Никита Гусев on 09.06.2021.
//

import Foundation
import Alamofire

protocol RestManager: class {
    func loadAllStocks(with tickers: [String],
                       completion:  @escaping ((Result<[DownloadedStockDto], NetworkError>) -> Void))
    func loadStocksTickers(by searchText: String,
                           completion: @escaping ((Result<[TickerDto], NetworkError>) -> Void))
    func cancelAllLoadingTasks()
}

protocol WebsocketManager: class {
    
}

protocol INetworkManager: WebsocketManager & RestManager {
    var downloadedStocks: [DownloadedStockDto] { get }
    
    func removeAllDownloadedStocks()
    func downloadData(from url: URL, completion: @escaping ((Data?) -> Void))
}

final class NetworkManager: INetworkManager {
    var downloadedStocks: [DownloadedStockDto] {
        return stockInfos.toArray
    }

    private var stockInfos = ThreadSafeArray<DownloadedStockDto>()
    
    func loadAllStocks(with tickers: [String],
                       completion: @escaping ((Result<[DownloadedStockDto], NetworkError>) -> Void)) {
        let limitedSize = 15
        let limitedTickers = tickers.prefix(limitedSize)
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadAllStocksDto(with: limitedTickers) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(self.downloadedStocks))
            }
        }
    }
    
    func loadStocksTickers(by searchText: String,
                           completion: @escaping ((Result<[TickerDto], NetworkError>) -> Void)) {
        let urlString = String(format: "https://finnhub.io/api/v1/search?q=%@&token=c0qeg5f48v6tskkorckg",
                               searchText)
        guard let lookupUrl = URL(string: urlString) else {
            completion(.failure(.invalidUrl)); return
        }
        self.handleLoadTickersRequest(requestUrl: lookupUrl, completion: completion)
    }
    
    func cancelAllLoadingTasks() {
        AF.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
    
    func removeAllDownloadedStocks() {
        self.stockInfos.removeAll()
    }
    
    func downloadData(from url: URL, completion: @escaping ((Data?) -> Void)) {
        AF.request(url).responseData { dataResponse in
            guard let data = dataResponse.data else { completion(nil); return }
            completion(data)
        }
    }
}

private extension NetworkManager {
    func loadAllStocksDto(with tickers: ArraySlice<String>, completion: ((NetworkError?) -> Void)) {
        let dispatchGroup = DispatchGroup()
        var limitExceeded = false
        tickers.forEach { ticker in
            dispatchGroup.enter()
            self.loadStockInfo(for: ticker) { error in
                if let error = error, error == NetworkError.limitExceeded {
                    DispatchQueue.global().async(flags: .barrier) {
                        limitExceeded = true
                        dispatchGroup.leave()
                    }
                } else {
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.wait()
        limitExceeded ? completion(.limitExceeded) : completion(nil)
    }
    
    func loadStockInfo(for ticker: String, completion: @escaping ((NetworkError?) -> Void)) {
        self.loadCompanyProfileInfo(for: ticker) { [weak self] companyProfileResult in
            guard let self = self else { completion(nil); return }
            self.handleCompanyProfileResult(companyProfileResult, completion: completion)
        }
    }
    
    func loadCompanyProfileInfo(for ticker: String,
                                completion: @escaping ((Result<CompanyProfileDto, NetworkError>) -> Void)) {
        let urlString = String(format: "https://finnhub.io/api/v1/stock/profile2?symbol=%@&token=c0qeg5f48v6tskkorckg",
                               ticker)
        guard let companyProfileUrl = URL(string: urlString) else {
            completion(.failure(.invalidUrl)); return
        }
        self.handleCompanyProfileRequest(requestUrl: companyProfileUrl, completion: completion)
    }
    
    func loadQuote(for companyProfile: CompanyProfileDto,
                   completion: @escaping ((Result<QuoteDto, NetworkError>) -> Void)) {
        let urlString = String(format: "https://finnhub.io/api/v1/quote?symbol=%@&token=c0qeg5f48v6tskkorckg",
                               companyProfile.ticker)
        guard let quoteUrl = URL(string: urlString) else {
            completion(.failure(.invalidUrl)); return
        }
        self.handleQuoteRequest(requestUrl: quoteUrl, completion: completion)
    }
    
    func saveDownloadedStock(with companyProfile: CompanyProfileDto, and quote: QuoteDto) {
        let downloadedStockDto = DownloadedStockDto(companyProfile: companyProfile,
                                                    quote: quote)
        if self.downloadsHasStock(with: companyProfile.ticker) == false {
            self.stockInfos.append(downloadedStockDto)
        }
    }
    
    func downloadsHasStock(with ticker: String) -> Bool {
        return self.stockInfos.toArray.contains(where: { element in
            let elementTicker = element.companyProfile.ticker
            return elementTicker == ticker
        })
    }
    
    func limitExceeded(in response: AFDataResponse<Any>) -> Bool {
        if let statusCode = response.response?.statusCode,
           statusCode == 429 {
           return true
        }
        return false
    }
    
    func handleLoadTickersRequest(requestUrl: URL,
                                             completion: @escaping ((Result<[TickerDto], NetworkError>) -> Void)) {
        AF.request(requestUrl).responseJSON { dataResponse in
            guard self.limitExceeded(in: dataResponse) == false else {
                completion(.failure(.limitExceeded)); return
            }
            guard let data = dataResponse.data,
                  let lookupDto = try? JSONDecoder().decode(LookupDto.self, from: data)
            else {
                completion(.failure(.noData)); return
            }
            let tickersDto = lookupDto.result
            print(tickersDto.count)
            completion(.success(tickersDto))
        }
    }
    
    func handleCompanyProfileRequest(requestUrl: URL,
                                     completion: @escaping ((Result<CompanyProfileDto, NetworkError>) -> Void)) {
        let request = self.createRequest(with: requestUrl, timeout: 5)
        request.responseJSON { dataResponse in
            guard self.limitExceeded(in: dataResponse) == false else {
                completion(.failure(.limitExceeded)); return
            }
            guard let data = dataResponse.data,
                  let companyProfileDto = try? JSONDecoder().decode(CompanyProfileDto.self, from: data)
            else {
                completion(.failure(.noData)); return
            }
            completion(.success(companyProfileDto))
        }
    }
    
    func handleQuoteRequest(requestUrl: URL,
                            completion: @escaping ((Result<QuoteDto, NetworkError>) -> Void)) {
        let request = AF.request(requestUrl) { urlRequest in
            urlRequest.timeoutInterval = 3
        }
        request.responseJSON { dataResponse in
            guard self.limitExceeded(in: dataResponse) == false else {
                completion(.failure(.limitExceeded)); return
            }
            guard let data = dataResponse.data,
                  let quoteDto = try? JSONDecoder().decode(QuoteDto.self, from: data)
            else {
                completion(.failure(.noData)); return
            }
            completion(.success(quoteDto))
        }
    }
    
    func createRequest(with url: URL, timeout: Double) -> DataRequest {
        let request = AF.request(url) { urlRequest in
            urlRequest.timeoutInterval = timeout
        }
        return request
    }
    
    func handleCompanyProfileResult(_ result: Result<CompanyProfileDto, NetworkError>,
                                    completion: @escaping ((NetworkError?) -> Void)) {
        switch result {
        case .failure(let companyProfileError):
            completion(companyProfileError)
        case .success(let companyProfile):
            self.loadQuote(for: companyProfile) { quoteResult in
                self.handleQuoteResult(quoteResult,
                                       companyProfile: companyProfile,
                                       completion: completion)
            }
        }
    }
    
    func handleQuoteResult(_ result: Result<QuoteDto, NetworkError>,
                           companyProfile: CompanyProfileDto,
                           completion: @escaping ((NetworkError?) -> Void)) {
        switch result {
        case .failure(let quoteError):
            completion(quoteError)
        case .success(let quote):
            self.saveDownloadedStock(with: companyProfile, and: quote)
            completion(nil)
        }
    }
}
