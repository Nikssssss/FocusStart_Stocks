//
//  NetworkManager.swift
//  Stocks
//
//  Created by Никита Гусев on 09.06.2021.
//

import Foundation
import Alamofire

protocol INetworkManager {
    var downloadedStocks: [DownloadedStockDto] { get }
    
    func removeAllDownloadedStocks()
    func downloadData(from url: URL, completion: @escaping ((Data?) -> Void))
    
    func loadAllStocks(with tickers: [String],
                       completion:  @escaping ((Result<[DownloadedStockDto], NetworkError>) -> Void))
    func loadStocksTickers(by searchText: String,
                           completion: @escaping ((Result<[TickerDto], NetworkError>) -> Void))
    func cancelAllLoadingTasks()
    func loadQuotes(for tickers: [String],
                    completion: @escaping ((Result<[RefreshQuoteInfo], NetworkError>) -> Void))
    func loadYearChartData(for ticker: String, from beginTime: Int64, to endTime: Int64,
                       completion: @escaping ((Result<ChartDto?, NetworkError>) -> Void))
    func loadMonthChartData(for ticker: String, from beginTime: Int64, to endTime: Int64,
                            completion: @escaping ((Result<ChartDto?, NetworkError>) -> Void))
    func loadDayChartData(for ticker: String, from beginTime: Int64, to endTime: Int64,
                          completion: @escaping ((Result<ChartDto?, NetworkError>) -> Void))
}

final class NetworkManager: INetworkManager {
    var downloadedStocks: [DownloadedStockDto] {
        return stockInfos.toArray
    }

    private var stockInfos = ThreadSafeArray<DownloadedStockDto>()
    
    func loadAllStocks(with tickers: [String],
                       completion: @escaping ((Result<[DownloadedStockDto], NetworkError>) -> Void)) {
        //divided by 2 because each stock request consists of requests for both company profile and quote
        let limitedSize = NetworkConstants.requestPerSecondLimit / 2
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
        let urlString = String(format: NetworkConstants.tickersUriWithSearchTextParam, searchText)
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
    
    func loadQuotes(for tickers: [String],
                    completion: @escaping ((Result<[RefreshQuoteInfo], NetworkError>) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            let refreshQuoteInfos = ThreadSafeArray<RefreshQuoteInfo>()
            let dispatchGroup = DispatchGroup()
            var limitExceedeed = false
            tickers.forEach { ticker in
                dispatchGroup.enter()
                self.loadQuote(for: ticker) { quoteResult in
                    switch quoteResult {
                    case .failure(let error):
                        if error == NetworkError.limitExceeded {
                            DispatchQueue.global().async(flags: .barrier) {
                                limitExceedeed = true
                                dispatchGroup.leave()
                            }
                            return
                        }
                        dispatchGroup.leave()
                    case .success(let quote):
                        let refreshQuoteInfo = RefreshQuoteInfo(ticker: ticker, quote: quote)
                        refreshQuoteInfos.append(refreshQuoteInfo)
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.wait()
            if limitExceedeed {
                completion(.failure(.limitExceeded))
            } else {
                completion(.success(refreshQuoteInfos.toArray))
            }
        }
    }
    
    func removeAllDownloadedStocks() {
        self.stockInfos.removeAll()
    }
    
    func downloadData(from url: URL, completion: @escaping ((Data?) -> Void)) {
        AF.request(url).responseData { dataResponse in
            guard let data = dataResponse.data else { completion(nil); return }
            completion(data)
        }.cacheResponse(using: ResponseCacher.cache)
    }
    
    func loadYearChartData(for ticker: String, from beginTime: Int64, to endTime: Int64,
                       completion: @escaping ((Result<ChartDto?, NetworkError>) -> Void)) {
        let parameters = String(format: NetworkConstants.yearChartTickerAndBeginTimeAndEndTimeParams,
                                ticker, beginTime, endTime)
        let urlString = NetworkConstants.chartDataUrl + parameters
        guard let url = URL(string: urlString) else { completion(.failure(.invalidUrl)); return }
        self.loadChartData(url: url, completion: completion)
    }
    
    func loadMonthChartData(for ticker: String, from beginTime: Int64, to endTime: Int64,
                            completion: @escaping ((Result<ChartDto?, NetworkError>) -> Void)) {
        let parameters = String(format: NetworkConstants.monthChartTickerAndBeginTimeAndEndTimeParams,
                                ticker, beginTime, endTime)
        let urlString = NetworkConstants.chartDataUrl + parameters
        guard let url = URL(string: urlString) else { completion(.failure(.invalidUrl)); return }
        self.loadChartData(url: url, completion: completion)
    }
    
    func loadDayChartData(for ticker: String, from beginTime: Int64, to endTime: Int64,
                          completion: @escaping ((Result<ChartDto?, NetworkError>) -> Void)) {
        let parameters = String(format: NetworkConstants.dayChartTickerAndBeginTimeAndEndTimeParams,
                                ticker, beginTime, endTime)
        let urlString = NetworkConstants.chartDataUrl + parameters
        guard let url = URL(string: urlString) else { completion(.failure(.invalidUrl)); return }
        self.loadChartData(url: url, completion: completion)
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
        let urlString = String(format: NetworkConstants.companyProfileUriWithTickerParam, ticker)
        guard let companyProfileUrl = URL(string: urlString) else {
            completion(.failure(.invalidUrl)); return
        }
        self.handleCompanyProfileRequest(requestUrl: companyProfileUrl, completion: completion)
    }
    
    func loadQuote(for ticker: String,
                   completion: @escaping ((Result<QuoteDto, NetworkError>) -> Void)) {
        let urlString = String(format: NetworkConstants.quoteUriWithTickerParam, ticker)
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
           statusCode == NetworkConstants.limitExcessHttpCode {
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
            completion(.success(tickersDto))
        }.cacheResponse(using: ResponseCacher.cache)
    }
    
    func handleCompanyProfileRequest(requestUrl: URL,
                                     completion: @escaping ((Result<CompanyProfileDto, NetworkError>) -> Void)) {
        let request = self.createRequest(with: requestUrl, timeout: NetworkConstants.requestTimeout)
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
        }.cacheResponse(using: ResponseCacher.cache)
    }
    
    func handleQuoteRequest(requestUrl: URL,
                            completion: @escaping ((Result<QuoteDto, NetworkError>) -> Void)) {
        let request = self.createRequest(with: requestUrl, timeout: NetworkConstants.requestTimeout)
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
        }.cacheResponse(using: ResponseCacher.cache)
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
            self.loadQuote(for: companyProfile.ticker) { quoteResult in
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
    
    func loadChartData(url: URL, completion: @escaping ((Result<ChartDto?, NetworkError>) -> Void)) {
        AF.request(url).responseJSON { dataResponse in
            guard self.limitExceeded(in: dataResponse) == false
            else { completion(.failure(.limitExceeded)); return }
            
            guard let data = dataResponse.data,
                  let chartDto = try? JSONDecoder().decode(ChartDto.self, from: data)
            else { completion(.failure(.noData)); return }
            
            completion(.success(chartDto))
        }.cacheResponse(using: ResponseCacher.cache)
    }
}
